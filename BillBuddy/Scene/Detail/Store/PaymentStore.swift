//
//  PaymentStore.swift
//  BillBuddy
//
//  Created by 김유진 on 2023/09/25.
//

import Foundation
import FirebaseFirestore

final class PaymentStore: ObservableObject {
    @Published var payments: [Payment] = []
    @Published var filteredPayments: [Payment] = []
    @Published var isFetchingList: Bool = false
    public var updateContentDate: Double = 0
    
    var members: [TravelCalculation.Member]
    var travelCalculationId: String
    var dbRef: CollectionReference
    
    var sumAllPayment: Int = 0
    
    init(travel: TravelCalculation) {
        self.travelCalculationId = travel.id
        self.dbRef = Firestore.firestore()
            .collection("TravelCalculation")
            .document(travel.id)
            .collection("Payment")
        self.members = travel.members
        self.updateContentDate = travel.updateContentDate
    }
    
    @MainActor
    func fetchAll() async {
        payments.removeAll()
        sumAllPayment = 0
        
        do {
            self.isFetchingList = true
            var tempPayment: [Payment] = []
            let snapshot = try await dbRef.order(by: "paymentDate").getDocuments()
            for document in snapshot.documents {
                let newPayment = try document.data(as: Payment.self)
                tempPayment.append(newPayment)
            }
            
            self.payments = tempPayment
            self.filteredPayments = tempPayment
            self.isFetchingList = false
        } catch {
            print("payment fetch false \(error)")
        }
    }
    
    func resetFilter() {
        filteredPayments = payments
    }
    
    func filterDate(date: Double) {
        filteredPayments = payments.filter({ (payment: Payment) in
            return date.todayRange() ~= (payment.paymentDate + 9 * 60 * 60)
        })
    }
    
    func filterDateCategory(date: Double, category: Payment.PaymentType) {
        filteredPayments = payments.filter({ (payment: Payment) in
            return date.todayRange() ~= (payment.paymentDate + 9 * 60 * 60) && payment.type == category
        })
    }
    
    func filterCategory(category: Payment.PaymentType) {
    
        filteredPayments = payments.filter({ (payment: Payment) in
            return payment.type == category
        })
    }
    
    func addPayment(newPayment: Payment) async {
        try! dbRef.addDocument(from: newPayment.self)
        await saveUpdateDate()
        await fetchAll()
    }
    
    func editPayment(payment: Payment) async {
        if let id = payment.id {
            self.isFetchingList = true
            await saveUpdateDate()
            try? dbRef.document(id).setData(from: payment)

            DispatchQueue.main.sync {
                if let index = payments.firstIndex(where: { $0.id == payment.id }) {
                    payments[index] = payment
                }
                
                if let index = filteredPayments.firstIndex(where: { $0.id == payment.id }) {
                    filteredPayments[index] = payment
                }
            }
            
            self.isFetchingList = false
        }
    }
    
    func deletePayment(payment: Payment) async {
        if let id = payment.id {
            self.isFetchingList = true
            do {
                await saveUpdateDate()
                DispatchQueue.main.sync {
                    if let index = payments.firstIndex(where: { $0.id == payment.id }) {
                        payments.remove(at: index)
                    }
                    
                    if let index = filteredPayments.firstIndex(where: { $0.id == payment.id }) {
                        filteredPayments.remove(at: index)
                    }
                }
                
                try await dbRef.document(id).delete()
            } catch {
                print("delete payment false")
            }
            
            self.isFetchingList = false
        }
    }
    
    func saveUpdateDate() async {
        do {
            let newUpdateDate = Date.now.timeIntervalSince1970
            try await Firestore.firestore()
                .collection(StoreCollection.travel.path)
                .document(self.travelCalculationId)
                .setData(["updateContentDate": newUpdateDate], merge: true)
            self.updateContentDate = newUpdateDate
        } catch {
            print("save date false")
        }
        // TravelCaluration UpdateDate최신화
        // - save
        // - edit
        // - detele
    }
}
