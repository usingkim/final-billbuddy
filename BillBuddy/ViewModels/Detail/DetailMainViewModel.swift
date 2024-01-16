//
//  DetailMainViewModel.swift
//  BillBuddy
//
//  Created by 김유진 on 1/2/24.
//

import Foundation
import Combine

@MainActor
final class DetailMainViewModel: ObservableObject {
    init(travel: TravelCalculation) {
        paymentService = PaymentService(travel: travel)
    }
    
    var paymentService: PaymentService
    private var cancellables: Set<AnyCancellable> = []
    
    @Published var filteredPayments: [Payment] = []
    
    @Published var selectMenu: String = "내역"
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
    
    func fetchAll() {
        paymentService.fetchAll()
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    print("Error fetching data: \(error.localizedDescription)")
                }
            } receiveValue: { payments in
                self.filteredPayments = payments
            }
            .store(in: &cancellables)
    }
    
    func fetchPaymentAndSettledAccount(paymentStore: PaymentServiceOrigin, travelDetailStore: TravelDetailStore, settlementExpensesStore: SettlementExpensesStore) {
        Task {
            filteredPayments = await paymentStore.fetchAll()
            settlementExpensesStore.setSettlementExpenses(payments: paymentStore.payments, members: travelDetailStore.travel.members)
        }
        selectedDate = 0
    }
    
    func deleteSelectedPayments(paymentStore: PaymentServiceOrigin, travelDetailStore: TravelDetailStore, settlementExpensesStore: SettlementExpensesStore) {
        Task {
            if let deleted = await paymentStore.deletePayments(payment: forDeletePayments) {
                filteredPayments = deleted
            }
            settlementExpensesStore.setSettlementExpenses(payments: paymentStore.payments, members: travelDetailStore.travel.members)
            isEditing.toggle()
        }
    }
    
    func whenChangeSelectedDate(paymentStore: PaymentServiceOrigin) {
        if selectedDate == 0 {
            filteredPayments = paymentStore.resetFilter()
        }
        else {
            filteredPayments = paymentStore.filterDate(date: selectedDate)
        }
    }
    
    func whenOpenView(paymentStore: PaymentServiceOrigin) {
        if selectedDate == 0 {
            filteredPayments = paymentStore.resetFilter()
        }
        else {
            filteredPayments = paymentStore.filterDate(date: selectedDate)
        }
    }
    
    func whenChangeSelectedCategory(paymentStore: PaymentServiceOrigin) {
        
        // 날짜 전체일때
        if selectedDate == 0 {
            // 선택된 카테고리가 있을때
            if let category = selectedCategory {
                filteredPayments = paymentStore.filterCategory(category: category)
            }
            // 카테고리 전체
            else {
                filteredPayments = paymentStore.resetFilter()
                selectedCategory = nil
            }
        }
        else {
            if let category = selectedCategory{
                filteredPayments = paymentStore.filterDateCategory(date: selectedDate, category: category)
            }
            else {
                selectedCategory = nil
                filteredPayments = paymentStore.filterDate(date: selectedDate)
            }
        }
    }
    
    func resetCategory() {
        selectedCategory = nil
    }
    
    func refresh(travelDetailStore: TravelDetailStore, paymentStore: PaymentServiceOrigin) {
//        if travelDetailStore.isChangedTravel {
            selectedCategory = nil
            selectedDate = 0
        Task {
            await filteredPayments = paymentStore.fetchAll()
        }
//        }
    }
    
    func addForDeletePayments(payment: Payment) {
        forDeletePayments.append(payment)
    }
    
    func resetForDeletePayments() {
        forDeletePayments = []
    }
    
    func deleteAPayment(paymentStore: PaymentServiceOrigin, travelDetailStore: TravelDetailStore, settlementExpensesStore: SettlementExpensesStore) {
        Task {
            if let payment = selectedPayment {
                if let deleted = await paymentStore.deletePayment(payment: payment) {
                    filteredPayments = deleted
                }
                settlementExpensesStore.setSettlementExpenses(payments: paymentStore.payments, members: travelDetailStore.travel.members)
            }
        }
    }
}
