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
    
    
    
    init(mode: PaymentManageMode, payment: Payment?, travelCalculation: TravelCalculation) {
        self.mode = mode
        self.payment = payment
        self.travelCalculation = travelCalculation
    }
    
}
