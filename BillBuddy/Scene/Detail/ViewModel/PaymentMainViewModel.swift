//
//  PaymentMainViewModel.swift
//  BillBuddy
//
//  Created by 김유진 on 1/1/24.
//

import Foundation

@MainActor
final class PaymentMainViewModel: ObservableObject {
    @Published var isShowingSelectCategorySheet: Bool = false
    @Published var isShowingDeletePayment: Bool = false
    @Published var selectedCategory: Payment.PaymentType?
    @Published var isEditing: Bool = false
    @Published var selection = Set<String>()
}
