//
//  EditTravelSheetView.swift
//  BillBuddy
//
//  Created by Ari on 10/16/23.
//

import SwiftUI

struct EditTravelSheetView: View {
    @EnvironmentObject private var userTravelStore: UserTravelStore
    @EnvironmentObject private var tabBarVisibilityStore: TabBarVisibilityStore
    
    @ObservedObject var travelListVM: TravelListViewModel

    let travel: Travel
    
    var body: some View {
        VStack {
            Button {
                travelListVM.isShowingEditSheet = false
                tabBarVisibilityStore.hideTabBar()
                travelListVM.isPresentedDateView = true
            } label: {
                HStack {
                    Image(.calendarCheck1)
                        .resizable()
                        .frame(width: 18, height: 18)
                        .padding(.trailing, 12)
                    
                    Text("날짜 관리")
                    
                    Spacer()
                }
                .padding([.bottom, .leading], 30)
                
            } //MARK: BUTTON1
            
            Button {
                travelListVM.isShowingEditSheet = false
                tabBarVisibilityStore.hideTabBar()
                travelListVM.isPresentedMemeberView = true
            } label: {
                
                HStack {
                    Image(.userSingleNeutralMale4)
                        .resizable()
                        .frame(width: 18, height: 18)
                        .padding(.trailing, 12)
                    
                    Text("인원 관리")
                    
                    Spacer()
                }
                .padding([.bottom, .leading], 30)
                
            } //MARK: BUTTON2
            
            Button {
                travelListVM.isShowingEditSheet = false
                tabBarVisibilityStore.hideTabBar()
                travelListVM.isPresentedSpendingView = true
            } label: {
                HStack {
                    Image(.script218)
                        .resizable()
                        .frame(width: 18, height: 18)
                        .padding(.trailing, 12)
                    
                    Text("결산 하기")
                    
                    Spacer()
                }
                .padding([.bottom, .leading], 30)
                
            } //MARK: BUTTON3
            
        } //MARK: VSTACK
        .font(.body04)
        .foregroundColor(.systemBlack)
    }
    
    
} //MARK: BODY


