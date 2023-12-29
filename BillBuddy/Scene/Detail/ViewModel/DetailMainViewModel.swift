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
    
    
    @Published var isFetchingList: Bool = false
    public var updateContentDate: Double = 0
    
    private var payments: [Payment] = []
    var filteredPayments: [Payment] = []
    private var members: [TravelCalculation.Member]
    private var dbRef: CollectionReference
    
    @Published var selection: String = "내역"
    @Published var selectedDate: Double = 0
    @Published var isShowingDateSheet: Bool = false
    
    init(travel: TravelCalculation) {
        self.dbRef = Firestore.firestore()
            .collection("TravelCalculation")
            .document(travel.id)
            .collection("Payment")
        self.members = travel.members
        self.updateContentDate = travel.updateContentDate
    }
    
    func fetchAll() async {
        payments.removeAll()
        
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
    
    func filterDate() {
        filteredPayments = payments.filter({ (payment: Payment) in
            print(payment.content, payment.paymentDate, selectedDate.todayRange(), selectedDate.todayRange() ~= payment.paymentDate)
            return selectedDate.todayRange() ~= payment.paymentDate
        })
        print("COUNT!!!!", filteredPayments.count)
    }
    
    func changeDate() {
        if selectedDate == 0 {
            resetFilter()
        }
        else {
            filterDate()
        }
    }
    
    func getSelectedDateString() -> String {
        return selectedDate.toDate().dateWeekYear
    }
    
    func getHowManyDays(startDate: Double) -> Int {
        return selectedDate.howManyDaysFromStartDate(startDate: startDate)
    }
}
