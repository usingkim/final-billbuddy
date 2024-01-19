//
//  DateManagementModifier.swift
//  BillBuddy
//
//  Created by 김유진 on 1/20/24.
//

import SwiftUI

struct DateManagementModifier: ViewModifier {
    @StateObject var dateManagementVM: DateManagementViewModel
    
    init(dateManagementVM: DateManagementViewModel) {
        _dateManagementVM = StateObject(wrappedValue: dateManagementVM)
    }

    func body(content: Content) -> some View {
        ZStack(alignment: .bottom) {
            content
            
            if dateManagementVM.isPresentedDateSheet {
                Rectangle()
                    .fill(.black.opacity(0.7))
                    .ignoresSafeArea()
                    .onTapGesture {
                        dateManagementVM.isPresentedDateSheet = false
                    }
                
                DateManagementCalendarView(
                    dateManagementVM: dateManagementVM
                )
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .modifier(
            CheckDateModifier(isPresented: $dateManagementVM.isPresentedAlert)
        )
        .animation(
            dateManagementVM.isPresentedDateSheet ? .spring(response: 0.25) : .none,
            value: dateManagementVM.isPresentedDateSheet
        )
        
    }
}
