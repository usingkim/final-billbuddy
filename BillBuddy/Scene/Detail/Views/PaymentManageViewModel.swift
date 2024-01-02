//
//  PaymentManageViewModel.swift
//  BillBuddy
//
//  Created by 김유진 on 1/2/24.
//

import Foundation

enum PaymentManageMode {
    case mainAdd
    case add
    case edit
}
@MainActor
final class PaymentManageViewModel: ObservableObject {
    var mode: PaymentManageMode
    @Published var payment: Payment?
    @Published var travelCalculation: TravelCalculation
    
    @Published var expandDetails: String = ""
    @Published var priceString: String = ""
    @Published var searchAddress: String = ""
    @Published var selectedCategory: Payment.PaymentType?
    @Published var paymentDate: Date = Date.now
    @Published var isShowingSelectTripSheet: Bool = false
    @Published var isShowingNoTravelAlert: Bool = false
    @Published var navigationTitleString: String = "지출 내역 추가"
    @Published var isShowingAlert: Bool = false
    @Published var participants: [Payment.Participant] = []
    @Published var isShowingMemberSheet: Bool = false
    
    @Published var isShowingDatePicker: Bool = false
    @Published var isShowingTimePicker: Bool = false
    @Published var paymentType: Int = 0 // 0: 1/n, 1: 개별
    @Published var selectedMember: TravelCalculation.Member = TravelCalculation.Member(name: "", advancePayment: 0, payment: 0)
    @Published var members: [TravelCalculation.Member] = []
    
    init(mode: PaymentManageMode, payment: Payment?, travelCalculation: TravelCalculation) {
        self.mode = mode
        self.payment = payment
        self.travelCalculation = travelCalculation
    }
    
    func setTitleString(userTravelStore: UserTravelStore) {
        if mode == .edit {
            navigationTitleString = "지출 내역 수정"
        }
        
        if mode == .mainAdd{
            isShowingSelectTripSheet = true
            if let first =  userTravelStore.travels.first {
                travelCalculation = first
            }
        }
    }
    
    func setTravel(travel: TravelCalculation) {
        travelCalculation = travel
        paymentDate = travel.startDate.toDate()
        isShowingSelectTripSheet = false
    }
    
    func setTravelAlertOrSheet(userTravelStore: UserTravelStore) {
        if userTravelStore.travels.isEmpty {
            isShowingNoTravelAlert = true
        }
        else {
            isShowingSelectTripSheet = true
        }
    }
    
    func setInitialValue() {
        switch(mode) {
        case .add:
            paymentDate = travelCalculation.startDate.toDate()
        case .mainAdd:
            paymentDate = travelCalculation.startDate.toDate()
        case .edit:
            if let payment = payment {
                selectedCategory = payment.type
                expandDetails = payment.content
                priceString = String(payment.payment)
                paymentDate = payment.paymentDate.toDate()
            }
        }
    }
    
    func setAddress() {
        if let p = payment {
            searchAddress = p.address.address
        }
    }
    
    func addPayment(paymentStore: PaymentService, settlementExpensesStore: SettlementExpensesStore, locationManager: LocationManager, notificationStore: NotificationStore) {
        let newPayment =
        Payment(type: selectedCategory ?? .etc, content: expandDetails, payment: Int(priceString) ?? 0, address: Payment.Address(address: locationManager.selectedAddress, latitude: locationManager.selectedLatitude, longitude: locationManager.selectedLongitude), participants: participants, paymentDate: paymentDate.timeIntervalSince1970)
        
        Task {
            await paymentStore.addPayment(newPayment: newPayment)
            settlementExpensesStore.setSettlementExpenses(payments: paymentStore.payments, members: travelCalculation.members)
        }
        
        PushNotificationManager.sendPushNotification(toTravel: travelCalculation, title: "\(travelCalculation.travelTitle)여행방", body: "지출이 추가 되었습니다.", senderToken: "senderToken")
        notificationStore.sendNotification(members: travelCalculation.members, notification: UserNotification(type: .travel, content: "\(travelCalculation.travelTitle)여행방에서 확인하지 않은 지출", contentId: "\(URLSchemeBase.scheme.rawValue)://travel?travelId=\(travelCalculation.id)", addDate: Date(), isChecked: false))
    }
    
    func mainAddPayment(paymentStore: PaymentService, settlementExpensesStore: SettlementExpensesStore, locationManager: LocationManager, notificationStore: NotificationStore, userTravelStore: UserTravelStore) {
        let newPayment =
        Payment(type: selectedCategory ?? .etc, content: expandDetails, payment: Int(priceString) ?? 0, address: Payment.Address(address: locationManager.selectedAddress, latitude: locationManager.selectedLatitude, longitude: locationManager.selectedLongitude), participants: participants, paymentDate: paymentDate.timeIntervalSince1970)
        userTravelStore.addPayment(travelCalculation: travelCalculation, payment: newPayment)
        
        PushNotificationManager.sendPushNotification(toTravel: travelCalculation, title: "\(travelCalculation.travelTitle)여행방", body: "지출이 추가 되었습니다.", senderToken: "senderToken")
        notificationStore.sendNotification(members: travelCalculation.members, notification: UserNotification(type: .travel, content: "\(travelCalculation.travelTitle)여행방에서 확인하지 않은 지출", contentId: "\(URLSchemeBase.scheme.rawValue)://travel?travelId=\(travelCalculation.id)", addDate: Date(), isChecked: false))
    }
    
    func editPayment(paymentStore: PaymentService, settlementExpensesStore: SettlementExpensesStore, locationManager: LocationManager, notificationStore: NotificationStore) {
        if let payment = payment {
            let newPayment = Payment(id: payment.id, type: selectedCategory ?? .etc, content: expandDetails, payment: Int(priceString) ?? 0, address: Payment.Address(address: locationManager.selectedAddress, latitude: locationManager.selectedLatitude, longitude: locationManager.selectedLongitude), participants: participants, paymentDate: paymentDate.timeIntervalSince1970)
            Task {
                await paymentStore.editPayment(payment: newPayment)
                settlementExpensesStore.setSettlementExpenses(payments: paymentStore.payments, members: travelCalculation.members)
            }
        }
    }
    
    func pressCompleteButton() -> PaymentFocusField? {
        if mode == .mainAdd && travelCalculation.travelTitle.isEmpty {
            isShowingSelectTripSheet = true
        }
        else if selectedCategory == nil {
            return .type
        }
        else if expandDetails.isEmpty {
            return .content
        }
        else if priceString.isEmpty {
            return .price
        }
        
        isShowingAlert = true
        return nil
    }
    
    func getTextButton() -> String {
        if mode == .edit {
            return "수정하기"
        }
        return "추가하기"
    }
    
}
