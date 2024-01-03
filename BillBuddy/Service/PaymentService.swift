//
//  PaymentStore.swift
//  BillBuddy
//
//  Created by 김유진 on 2023/09/25.
//

import Foundation
import FirebaseFirestore

@MainActor
final class PaymentService: ObservableObject {
    
    @Published var payments: [Payment] = []
    @Published var isFetchingList: Bool = false
    public var updateContentDate: Double = 0
    
    var members: [TravelCalculation.Member]
    var travelCalculationId: String
    var dbRef: CollectionReference
    var isPaymentSettled: Bool
    var sumAllPayment: Int = 0
    var paymentDates: [Date] {
        payments.map { $0.paymentDate.toDate() }
    }
    
    init(travel: TravelCalculation) {
        self.travelCalculationId = travel.id
        self.dbRef = Firestore.firestore()
            .collection("TravelCalculation")
            .document(travel.id)
            .collection("Payment")
        self.members = travel.members
        self.updateContentDate = travel.updateContentDate
        self.isPaymentSettled = travel.isPaymentSettled
    }
    
    func fetchAll() async -> [Payment] {
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
            self.isFetchingList = false
            return tempPayment
        } catch {
            print("payment fetch false \(error)")
        }
        
        return []
    }
    
    func resetFilter() -> [Payment] {
        return payments
    }
    
    func filterDate(date: Double) -> [Payment] {
        return payments.filter({ (payment: Payment) in
            print(payment.content, payment.paymentDate, date.todayRange(), date.todayRange() ~= payment.paymentDate)
            return date.todayRange() ~= payment.paymentDate
        })
    }
    
    func filterDateCategory(date: Double, category: Payment.PaymentType) -> [Payment] {
        return payments.filter({ (payment: Payment) in
            return date.todayRange() ~= payment.paymentDate && payment.type == category
        })
    }
    
    func filterCategory(category: Payment.PaymentType) -> [Payment] {
        return payments.filter({ (payment: Payment) in
            return payment.type == category
        })
    }
    
    func addPayment(newPayment: Payment) async -> [Payment]? {
        if isPaymentSettled { return nil }
        try! dbRef.addDocument(from: newPayment.self)
        await saveUpdateDate()
        return await fetchAll()
    }
    
    func editPayment(payment: Payment) async -> [Payment]? {
        if isPaymentSettled { return nil }
        if let id = payment.id {
            self.isFetchingList = true
            await saveUpdateDate()
            try? dbRef.document(id).setData(from: payment)
            if let index = payments.firstIndex(where: { $0.id == payment.id }) {
                payments[index] = payment
            }
            self.isFetchingList = false
            return payments
        }
        return nil
    }
    
    func deletePayment(payment: Payment) async -> [Payment]? {
        if isPaymentSettled { return nil }
        if let id = payment.id {
            self.isFetchingList = true
            do {
                await saveUpdateDate()
                if let index = payments.firstIndex(where: { $0.id == payment.id }) {
                    payments.remove(at: index)
                }
                
                
                try await dbRef.document(id).delete()
            } catch {
                print("delete payment false")
            }
            
            self.isFetchingList = false
            return payments
        }
        return nil
    }
    
    func deletePayments(payment: [Payment]) async -> [Payment]? {
        if isPaymentSettled { return nil }
        var result: [Payment]?
        for p in payment {
            result = await self.deletePayment(payment: p)
        }
        return result
    }
    
    func saveUpdateDate() async {
        if isPaymentSettled { return }
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
