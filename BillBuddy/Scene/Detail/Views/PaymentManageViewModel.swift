//
//  PaymentManageViewModel.swift
//  BillBuddy
//
//  Created by 김유진 on 1/2/24.
//

import Foundation

@MainActor
final class PaymentManageViewModel: ObservableObject {
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
    
}
