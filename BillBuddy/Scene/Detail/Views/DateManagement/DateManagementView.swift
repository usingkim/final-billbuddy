//
//  DateManagementView.swift
//  BillBuddy
//
//  Created by 윤지호 on 12/16/23.
//

import SwiftUI

struct DateManagementView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var userTravelStore: UserTravelStore
    @EnvironmentObject private var travelDetailStore: TravelDetailStore
    
    @StateObject private var dateManagementVM: DateManagementViewModel
    
    init(entryViewType: EntryViewType, travel: Travel, paymentDates: [Date]) {
        _dateManagementVM = StateObject(wrappedValue: 
                                            DateManagementViewModel(
                                                entryViewType: entryViewType,
                                                travel: travel,
                                                paymentDates: paymentDates
                                            ))
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            VStack(spacing: 0) {
                Rectangle()
                    .foregroundStyle(Color.gray100)
            }
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(Color.gray200, lineWidth: 1)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay {
                    HStack(spacing: 0) {
                        Text("날짜")
                            .font(.body02)
                        Spacer()
                        Button(dateManagementVM.getDatesString()) {
                            if dateManagementVM.travel.isPaymentSettled {
                                dateManagementVM.isPresentedSettledAlert = true
                            } else {
                                dateManagementVM.isPresentedDateSheet = true
                            }
                        }
                        .frame(width: 100, height: 30)
                        .background(Color.myPrimaryLight)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .font(Font.caption02)
                        .foregroundStyle(Color.myPrimary)
                        .font(.body04)
                    }
                    .padding(.horizontal, 16)
                }
                .frame(width: 361, height: 52)
                .padding(.top, 16)
            
        }
        .alert("정산된 여행입니다.", isPresented: $dateManagementVM.isPresentedSettledAlert) {
            Button("확인") {
                dateManagementVM.isPresentedSettledAlert = false
            }
        }
        .onAppear {
            dateManagementVM.getPaymentDates()
        }
        .modifier(
            DateManagementModifier(dateManagementVM: dateManagementVM)
        )
        .ignoresSafeArea(.all, edges: .bottom)
        .navigationBarBackButtonHidden()
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button(action: {
                    dismiss()
                }, label: {
                    Image(.arrowBack)
                        .resizable()
                        .frame(width: 24, height: 24)
                })
            }
            ToolbarItem(placement: .principal) {
                Text("날짜 관리")
                    .font(.title05)
            }
        }
    }
    
    
}
