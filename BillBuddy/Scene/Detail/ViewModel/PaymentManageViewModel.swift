//
//  PaymentManageViewModel.swift
//  BillBuddy
//
//  Created by 김유진 on 1/1/24.
//

import Foundation

final class PaymentManageViewModel: ObservableObject {
    
    init(travelCalculation: TravelCalculation) {
        self.travelCalculation = travelCalculation
        paymentDate = travelCalculation.startDate.toDate()
    }
    
    
    init(payment: Payment, travelCalculation: TravelCalculation) {
        selectedCategory = payment.type
        expandDetails = payment.content
        priceString = String(payment.payment)
        paymentDate = payment.paymentDate.toDate()
        searchAddress = payment.address.address
        
        self.travelCalculation = travelCalculation
    }
    
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
    
    var locationManager = LocationManager()
    
    func addPayment() {
        let newPayment =
        Payment(type: selectedCategory ?? .etc, content: expandDetails, payment: Int(priceString) ?? 0, address: Payment.Address(address: locationManager.selectedAddress, latitude: locationManager.selectedLatitude, longitude: locationManager.selectedLongitude), participants: participants, paymentDate: paymentDate.timeIntervalSince1970)
        
        Task {
//            await paymentStore.addPayment(newPayment: newPayment)
//            settlementExpensesStore.setSettlementExpenses(payments: paymentStore.payments, members: self.travelCalculation.members)
        }
        
        PushNotificationManager.sendPushNotification(toTravel: travelCalculation, title: "\(travelCalculation.travelTitle)여행방", body: "지출이 추가 되었습니다.", senderToken: "senderToken")
//        notificationStore.sendNotification(members: travelCalculation.members, notification: UserNotification(type: .travel, content: "\(travelCalculation.travelTitle)여행방에서 확인하지 않은 지출", contentId: "\(URLSchemeBase.scheme.rawValue)://travel?travelId=\(travelCalculation.id)", addDate: Date(), isChecked: false))
    }
    
    func mainAddPayment() {
        let newPayment =
        Payment(type: selectedCategory ?? .etc, content: expandDetails, payment: Int(priceString) ?? 0, address: Payment.Address(address: locationManager.selectedAddress, latitude: locationManager.selectedLatitude, longitude: locationManager.selectedLongitude), participants: participants, paymentDate: paymentDate.timeIntervalSince1970)
//        userTravelStore.addPayment(travelCalculation: travelCalculation, payment: newPayment)
        
        PushNotificationManager.sendPushNotification(toTravel: travelCalculation, title: "\(travelCalculation.travelTitle)여행방", body: "지출이 추가 되었습니다.", senderToken: "senderToken")
//        notificationStore.sendNotification(members: travelCalculation.members, notification: UserNotification(type: .travel, content: "\(travelCalculation.travelTitle)여행방에서 확인하지 않은 지출", contentId: "\(URLSchemeBase.scheme.rawValue)://travel?travelId=\(travelCalculation.id)", addDate: Date(), isChecked: false))
    }
    
    func editPayment() {
//        if let payment = payment {
//            let newPayment = Payment(id: payment.id, type: selectedCategory ?? .etc, content: expandDetails, payment: Int(priceString) ?? 0, address: Payment.Address(address: locationManager.selectedAddress, latitude: locationManager.selectedLatitude, longitude: locationManager.selectedLongitude), participants: participants, paymentDate: paymentDate.timeIntervalSince1970)
//            Task {
//                await paymentStore.editPayment(payment: newPayment)
//                settlementExpensesStore.setSettlementExpenses(payments: paymentStore.payments, members: self.travelCalculation.members)
//            }
//        }
    }
    
    
}
