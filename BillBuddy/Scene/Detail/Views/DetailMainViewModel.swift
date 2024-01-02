//
//  DetailMainViewModel.swift
//  BillBuddy
//
//  Created by 김유진 on 1/2/24.
//

import Foundation

@MainActor
final class DetailMainViewModel: ObservableObject {
    var selectMenu: String = "내역"
    @Published var selectedDate: Double = 0
    @Published var isShowingDateSheet: Bool = false
    @Published var isShowingSelectCategorySheet: Bool = false
    @Published var isShowingDeletePayment: Bool = false
    @Published var selectedCategory: Payment.PaymentType?
    @Published var isEditing: Bool = false
    @Published var selection = Set<String>()
    @Published var forDeletePayments: [Payment] = []
    @Published var isShowingDeletePaymentAlert: Bool = false
    @Published var selectedPayment: Payment?
    
    func fetchPaymentAndSettledAccount(paymentStore: PaymentService, travelDetailStore: TravelDetailStore, settlementExpensesStore: SettlementExpensesStore) {
        Task {
            await paymentStore.fetchAll()
            settlementExpensesStore.setSettlementExpenses(payments: paymentStore.payments, members: travelDetailStore.travel.members)
        }
        selectedDate = 0
    }
    
    func deleteSelectedPayments(paymentStore: PaymentService, travelDetailStore: TravelDetailStore, settlementExpensesStore: SettlementExpensesStore) {
        Task {
            await paymentStore.deletePayments(payment: forDeletePayments)
            settlementExpensesStore.setSettlementExpenses(payments: paymentStore.payments, members: travelDetailStore.travel.members)
            isEditing.toggle()
        }
    }
    
    func whenChangeSelectedDate(paymentStore: PaymentService) {
        if selectedDate == 0 {
            paymentStore.resetFilter()
        }
        else {
            paymentStore.filterDate(date: selectedDate)
        }
    }
    
    func whenChangeSelectedCategory(paymentStore: PaymentService) {
        
        // 날짜 전체일때
        if selectedDate == 0 {
            // 선택된 카테고리가 있을때
            if let category = selectedCategory {
                paymentStore.filterCategory(category: category)
            }
            // 카테고리 전체
            else {
                paymentStore.resetFilter()
                selectedCategory = nil
            }
        }
        else {
            if let category = selectedCategory{
                paymentStore.filterDateCategory(date: selectedDate, category: category)
            }
            else {
                selectedCategory = nil
                paymentStore.filterDate(date: selectedDate)
            }
        }
    }
    
    func resetCategory() {
        selectedCategory = nil
    }
    
    func refresh(travelDetailStore: TravelDetailStore) {
        if travelDetailStore.isChangedTravel {
            selectedCategory = nil
            selectedDate = 0
        }
    }
    
    func addForDeletePayments(payment: Payment) {
        forDeletePayments.append(payment)
    }
    
    func resetForDeletePayments() {
        forDeletePayments = []
    }
    
    func deleteAPayment(paymentStore: PaymentService, travelDetailStore: TravelDetailStore, settlementExpensesStore: SettlementExpensesStore) {
        Task {
            if let payment = selectedPayment {
                await paymentStore.deletePayment(payment: payment)
                settlementExpensesStore.setSettlementExpenses(payments: paymentStore.payments, members: travelDetailStore.travel.members)
            }
        }
    }
}
