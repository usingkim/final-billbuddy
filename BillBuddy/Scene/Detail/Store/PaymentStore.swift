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
    
    var members: [TravelCalculation.Member]
    var travelCalculationId: String
    var dbRef: CollectionReference
    
    var sumAllPayment: Int = 0
    
    init(travel: TravelCalculation) {
        self.travelCalculationId = travel.id
        self.members = travel.members
        self.dbRef = Firestore.firestore().collection("TravelCalculation").document(travelCalculationId).collection("Payment")
    }
    
    @MainActor
    func fetchAll(member: [TravelCalculation.Member] = []) async {
        var member = member.isEmpty ? self.members : member
        payments.removeAll()
        sumAllPayment = 0
        
        do {
            var tempPayment: [Payment] = []
            let snapshot = try await dbRef.getDocuments()
            for document in snapshot.documents {
                let newPayment = try document.data(as: Payment.self)
                tempPayment.append(newPayment)
            }
            
            self.payments = tempPayment
            self.filteredPayments = tempPayment
            
        } catch {
            print("payment fetch false \(error)")
        }
        
//        dbRef.getDocuments { snapshot, error in
//            if let snapshot {
//                var tempPayment: [Payment] = []
//                
//                for doc in snapshot.documents {
//                    
//                    let id: String = doc.documentID
//                    let docData = doc.data()
//                    
//                    let typeString: String = docData["type"] as? String ?? ""
//                    let type: Payment.PaymentType = Payment.PaymentType.fromRawString(typeString)
//                    
//                    let content: String = docData["content"] as? String ?? ""
//                    let price: Int = docData["payment"] as? Int ?? 0
//                    let paymentDate: Double = docData["paymentDate"] as? Double ?? 0
//                    
//                    let addressDict = docData["address"] as? [String: Any] ?? ["address": "", "latitude": 0, "longitude": 0]
//                    let address: Payment.Address = Payment.Address(address: addressDict["address"] as? String ?? "", latitude: addressDict["latitude"] as? Double ?? 0, longitude: addressDict["longitude"] as? Double ?? 0)
//                    
//                    let participantsDict = docData["participants"] as? [[String: Any]] ?? []
//                    var participants: [Payment.Participant] = []
//                    for p in participantsDict {
//                        let memberId = p["memberId"] as? String ?? ""
//                        let payment = p["payment"] as? Int ?? 0
//                        
//                        participants.append(Payment.Participant(memberId: memberId, payment: payment))
//                    }
//                    
//                    let newPayment = Payment(id: id, type: type, content: content, payment: price, address: address, participants: participants, paymentDate: paymentDate)
//                    
//                    tempPayment.append(newPayment)
//                    
//                    self.sumAllPayment += price
//                }
//                
//                DispatchQueue.main.async {
//                    self.payments = tempPayment
//                    self.filteredPayments = tempPayment
//                }
//                
//            }
//        }
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
    
    func addPayment(newPayment: Payment) {
        try! dbRef.addDocument(from: newPayment.self)
        Task {
            await fetchAll()
        }
    }
    
    func editPayment(payment: Payment) {
        if let id = payment.id {
            try? dbRef.document(id).setData(from: payment)
        }
    }
    
    func deletePayment(payment: Payment) {
        if let id = payment.id {
            dbRef.document(id).delete()
            
            if let index = payments.firstIndex(where: { $0.id == payment.id }) {
                payments.remove(at: index)
            }
        }
    }
}
