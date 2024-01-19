//
//  PaymentStore.swift
//  BillBuddy
//
//  Created by 김유진 on 2023/09/25.
//

import Foundation
import FirebaseFirestore

/// Payment DB 관련 구버전 Store
/// 참고할 부분이 있을거같아서 남겨둔다.

@MainActor
final class PaymentStore: ObservableObject {
    @Published var payments: [Payment] = []
    @Published var isFetchingList: Bool = false
    public var updateContentDate: Double = 0
    
    private var members: [Travel.Member]
    private var travelCalculationId: String
    private var dbRef: CollectionReference
    private var isPaymentSettled: Bool
    private var sumAllPayment: Int = 0
    
    var paymentDates: [Date] {
        payments.map { $0.paymentDate.toDate() }
    }
    
    init(travel: Travel) {
        self.travelCalculationId = travel.id
        self.dbRef = Firestore.firestore()
            .collection(StoreCollection.travel.path)
            .document(travel.id)
            .collection(StoreCollection.payment.path)
        self.members = travel.members
        self.updateContentDate = travel.updateContentDate
        self.isPaymentSettled = travel.isPaymentSettled
    }
    
    func fetchAll() async -> [Payment] {
        payments.removeAll()
        sumAllPayment = 0
        
        var tempPayment: [Payment] = []
        do {
            self.isFetchingList = true
            let snapshot = try await dbRef.order(by: "paymentDate").getDocuments()
            for document in snapshot.documents {
                let newPayment = try document.data(as: Payment.self)
                tempPayment.append(newPayment)
            }
            self.payments = tempPayment
            self.isFetchingList = false
        } catch {
            print("payment fetch false \(error)")
        }
        
        return tempPayment
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
    }
    
}
