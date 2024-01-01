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
    @Published var filteredPayments: [Payment] = []
    private var members: [TravelCalculation.Member]
    private var dbRef: CollectionReference
    
    @Published var selection: String = "내역"
    @Published var selectedDate: Double = 0
    @Published var isShowingDateSheet: Bool = false
    
    var forDeletePayments: [Payment] = []
    
    private var id: String = ""
    
    init(travel: TravelCalculation) {
        self.dbRef = Firestore.firestore()
            .collection("TravelCalculation")
            .document(travel.id)
            .collection("Payment")
        self.members = travel.members
        self.updateContentDate = travel.updateContentDate
        self.id = travel.id
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
            return selectedDate.todayRange() ~= payment.paymentDate
        })
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
    
    func filterDateCategory(category: Payment.PaymentType) {
        filteredPayments = payments.filter({ (payment: Payment) in
            return selectedDate.todayRange() ~= payment.paymentDate && payment.type == category
        })
    }
    
    func filterCategory(category: Payment.PaymentType) {
        filteredPayments = payments.filter({ (payment: Payment) in
            return payment.type == category
        })
    }
    
    func saveUpdateDate() async {
//        if isPaymentSettled == true { return }
        do {
            let newUpdateDate = Date.now.timeIntervalSince1970
            try await Firestore.firestore()
                .collection(StoreCollection.travel.path)
                .document(self.id)
                .setData(["updateContentDate": newUpdateDate], merge: true)
            self.updateContentDate = newUpdateDate
        } catch {
            print("save date false")
        }
    }
    
    func deletePayment(payment: Payment) async {
//        if isPaymentSettled == true { return }
        if let id = payment.id {
            self.isFetchingList = true
            do {
                await saveUpdateDate()
                if let index = payments.firstIndex(where: { $0.id == payment.id }) {
                    payments.remove(at: index)
                }
                
                if let index = filteredPayments.firstIndex(where: { $0.id == payment.id }) {
                    filteredPayments.remove(at: index)
                }
                
                try await dbRef.document(id).delete()
            } catch {
                print("delete payment false")
            }
            
            self.isFetchingList = false
        }
    }
    
    func deletePayments() async {
//        if isPaymentSettled == true { return }
        for p in forDeletePayments {
            await self.deletePayment(payment: p)
        }
    }
    
    func deleteSelectedPayments() {
        Task {
            await deletePayments()
//            settlementExpensesStore.setSettlementExpenses(payments: detailMainViewModel.payments, members: travelDetailStore.travel.members)
        }
    }
}
