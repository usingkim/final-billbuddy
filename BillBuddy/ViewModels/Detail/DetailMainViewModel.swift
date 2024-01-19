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
    
    var paymentService: PaymentService
    
    init(travel: Travel) {
        paymentService = PaymentService(travel: travel)
        self.updateContentDate = travel.updateContentDate
    }
    
    @Published var isFetchingList: Bool = false
    
    private var cancellables: Set<AnyCancellable> = []
    private var updateContentDate: Double
    
    @Published var payments: [Payment] = []
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
    
    var paymentDates: [Date] {
        payments.map { $0.paymentDate.toDate() }
    }
    
    func isUpdated(travelDetailStore: TravelDetailStore) -> Bool {
        return travelDetailStore.isChangedTravel &&
            updateContentDate != travelDetailStore.travel.updateContentDate &&
            !isFetchingList
    }
    
    func fetchAll(completion: @escaping ([Payment]) -> Void) {
        self.isFetchingList = true
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
                self.payments = payments
                self.resetFilter()
                completion(payments)
            }
            .store(in: &cancellables)
        self.isFetchingList = false
    }
    
    func deleteData(deleteData: Payment) {
        self.isFetchingList = true
        paymentService.deleteData(deleteData: deleteData)
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    print("Error fetching data: \(error.localizedDescription)")
                }
            } receiveValue: { _ in
                if let idx = self.payments.firstIndex(where: { find in
                    find.id == deleteData.id
                }) {
                    self.payments.remove(at: idx)
                }
            }
            .store(in: &cancellables)
        updateDate()
        self.isFetchingList = false
    }
    
    func fetchPaymentAndSettledAccount(travelDetailStore: TravelDetailStore, settlementExpensesStore: SettlementExpensesStore) {
        self.fetchAll { payments in
            self.resetFilter()
            settlementExpensesStore.setSettlementExpenses(payments: payments, members: travelDetailStore.travel.members)
            self.selectedDate = 0
        }
    }
    
    func deleteSelectedPayments(travelDetailStore: TravelDetailStore, settlementExpensesStore: SettlementExpensesStore) {
        for payment in forDeletePayments {
            deleteData(deleteData: payment)
        }
        settlementExpensesStore.setSettlementExpenses(payments: self.payments, members: travelDetailStore.travel.members)
        isEditing.toggle()
    }
    
    func whenChangeSelectedDate() {
        if selectedDate == 0 {
            resetFilter()
        }
        else {
            filterDate(date: selectedDate)
        }
    }
    
    func whenOpenView() {
        if selectedDate == 0 {
            resetFilter()
        }
        else {
            filterDate(date: selectedDate)
        }
    }
    
    func whenChangeSelectedCategory() {
        
        // 날짜 전체일때
        if selectedDate == 0 {
            // 선택된 카테고리가 있을때
            if let category = selectedCategory {
                filterCategory(category: category)
            }
            // 카테고리 전체
            else {
                resetFilter()
                selectedCategory = nil
            }
        }
        else {
            if let category = selectedCategory{
                filterDateCategory(date: selectedDate, category: category)
            }
            else {
                selectedCategory = nil
                filterDate(date: selectedDate)
            }
        }
    }
    
    func resetCategory() {
        selectedCategory = nil
    }
    
    private func filterDate(date: Double) {
        filteredPayments = payments.filter({ (payment: Payment) in
            print(payment.content, payment.paymentDate, date.todayRange(), date.todayRange() ~= payment.paymentDate)
            return date.todayRange() ~= payment.paymentDate
        })
    }
    
    private func filterDateCategory(date: Double, category: Payment.PaymentType){
        filteredPayments =  payments.filter({ (payment: Payment) in
            return date.todayRange() ~= payment.paymentDate && payment.type == category
        })
    }
    
    private func filterCategory(category: Payment.PaymentType) {
        filteredPayments = payments.filter({ (payment: Payment) in
            return payment.type == category
        })
    }
    
    func refresh(travelDetailStore: TravelDetailStore) {
        if travelDetailStore.isChangedTravel {
            selectedCategory = nil
            selectedDate = 0
            self.fetchAll(completion: {_ in })
        }
    }
    
    func addForDeletePayments(payment: Payment) {
        forDeletePayments.append(payment)
    }
    
    func resetForDeletePayments() {
        forDeletePayments = []
    }
    
    func deleteAPayment(travelDetailStore: TravelDetailStore, settlementExpensesStore: SettlementExpensesStore) {
        if let payment = selectedPayment {
            deleteData(deleteData: payment)
            updateDate()
            Task {
                settlementExpensesStore.setSettlementExpenses(payments: self.payments, members: travelDetailStore.travel.members)
            }
        }
    }
    
    func resetFilter() {
        selectedDate = 0
        selectedCategory = nil
        filteredPayments = payments
    }
    
    func updateDate() {
        paymentService.updateDate()
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    print("Error fetching data: \(error.localizedDescription)")
                }
            } receiveValue: { date in
                self.updateContentDate = date
            }
            .store(in: &cancellables)
    }
}
