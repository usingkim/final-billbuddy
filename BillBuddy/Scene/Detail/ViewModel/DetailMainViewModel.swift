//
//  DetailMainViewModel.swift
//  BillBuddy
//
//  Created by 김유진 on 12/30/23.
//

import Foundation
import FirebaseFirestore

@MainActor
final class DetailMainViewModel: ObservableObject {
    
    @Published var payments: [Payment] = []
    @Published var filteredPayments: [Payment] = []
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
    
    @Published var selection: String = "내역"
    @Published var selectedDate: Double = 0
    @Published var isShowingDateSheet: Bool = false
    
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
    
    func showNewButton() {
        
    }
    
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
            print(payment.content, payment.paymentDate, date.todayRange(), date.todayRange() ~= payment.paymentDate)
            return date.todayRange() ~= payment.paymentDate
        })
        print("COUNT!!!!", filteredPayments.count)
    }
    
    func changeDate(newDate: Double) {
        if selectedDate == 0 {
            resetFilter()
        }
        else {
            filterDate(date: newDate)
        }
    }
    
}
