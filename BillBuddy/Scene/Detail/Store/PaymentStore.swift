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
    
    var members: [TravelCalculation.Member]
    var travelCalculationId: String
    var dbRef: CollectionReference
    
    var sumAllPayment: Int = 0
    
    init(travel: TravelCalculation) {
        self.travelCalculationId = travel.id
        self.members = travel.members
        self.dbRef = Firestore.firestore()
            .collection("TravelCalculation")
            .document(travelCalculationId)
            .collection("Payment")
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
            return payment.paymentDate.todayRange() == date.todayRange()
        })
    }
    
    func filterDateCategory(date: Double, category: Payment.PaymentType) {
        filteredPayments = payments.filter({ (payment: Payment) in
            return payment.paymentDate.todayRange() == date.todayRange() && payment.type == category
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
            try? dbRef.document(id).setData(from: payment)
            

            //FIXME: fetchAll -> fetch 안하도록 ..
            await saveUpdateDate()
            await fetchAll()
            
            
//            if let index = payments.firstIndex(where: { $0.id == payment.id }) {
//                payments[index] = payment
//            }
        }
    }
    
    func deletePayment(payment: Payment) async {
        if let id = payment.id {
            do {
                try await dbRef.document(id).delete()
                
                if let index = payments.firstIndex(where: { $0.id == payment.id }) {
                    payments.remove(at: index)
                }
                
                await saveUpdateDate()
                //FIXME: fetchAll -> fetch 안하도록 .. 삭제가 안되는 문제 o
                await fetchAll()
            } catch {
                print("delete payment false")
            }
        }
    }
    
    func saveUpdateDate() async {
        do {
            // FIXME: 데이터 쟤만 들어감 ...
            try await Firestore.firestore().collection(StoreCollection.travel.path).document(self.travelCalculationId).setData(["updateContentDate":Date.now.timeIntervalSince1970], merge: true)
        } catch {
            print("save date false")
        }
        // TravelCaluration UpdateDate최신화
        // - save
        // - edit
        // - detele
    }
}
