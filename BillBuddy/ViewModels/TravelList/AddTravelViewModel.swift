//
//  AddTravelViewModel.swift
//  BillBuddy
//
//  Created by 김유진 on 1/4/24.
//

import Foundation

@MainActor
final class AddTravelViewModel: ObservableObject {
    @Published var travelTitle: String = ""
    @Published var selectedMember = 1
    @Published var startDate: Date = Date()
    @Published var endDate: Date = Date() - 1
    @Published var isShowingCalendarView = false
}
