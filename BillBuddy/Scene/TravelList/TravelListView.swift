//
//  TravelListView.swift
//  BillBuddy
//
//  Created by 윤지호 on 2023/09/22.
//

import SwiftUI

struct TravelListView: View {
    @EnvironmentObject private var notificationStore: NotificationService
    @EnvironmentObject private var tabBarVisibilityStore: TabBarVisibilityStore
    @EnvironmentObject private var nativeAdViewModel: NativeAdViewModel
    @EnvironmentObject private var userService: UserService
    @EnvironmentObject private var tabViewStore: TabViewModel
    
    @StateObject private var travelDetailStore: TravelDetailStore = TravelDetailStore()
    @ObservedObject var floatingButtonMenuStore: FloatingButtonMenuStore
    @StateObject private var travelListVM: TravelListViewModel = TravelListViewModel()
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                HStack {
                    travelFilterButton
                    Spacer()
                }
                .padding(.leading, 20)
                
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 0) {
                        if travelListVM.isFetchingList || !travelListVM.isFetchedFirst {
                            progressView
                        }
                        else {
                            if travelListVM.filteredTravels.isEmpty {
                                switch(travelListVM.selectedFilter) {
                                case .paymentInProgress:
                                    Text("정산 중인 여행이 없습니다.")
                                        .font(.body04)
                                        .foregroundColor(.gray600)
                                        .padding(.top, 270)
                                        .lineLimit(1)
                                        .lineSpacing(25)
                                case .paymentSettled:
                                    Text("정산이 완료된 여행이 없습니다.")
                                        .font(.body04)
                                        .foregroundColor(.gray600)
                                        .padding(.top, 270)
                                        .lineLimit(1)
                                        .lineSpacing(25)
                                }
                            }
                            else {
                                ForEach(travelListVM.filteredTravels) { travel in
                                    Button {
                                        tabViewStore.pushView(type: .travel, travel: travel)
                                    } label: {
                                        HStack {
                                            VStack(alignment: .leading) {
                                                Text(travel.travelTitle)
                                                    .font(.body01)
                                                    .foregroundColor(.black)
                                                    .padding(.bottom, 5)
                                                
                                                Text("\(travel.startDate.toFormattedYearandMonthandDay()) - \(travel.endDate.toFormattedYearandMonthandDay())")
                                                    .font(.caption02)
                                                    .foregroundColor(Color.gray600)
                                            }
                                            .padding(.leading, 26)
                                            
                                            Spacer()
                                            
                                            Button {
                                                travelDetailStore.setTravel(travel: travel)
                                                travelListVM.selectedTravel = travel
                                                travelListVM.isShowingEditSheet.toggle()
                                            } label: {
                                                Image(.steps13)
                                                    .resizable()
                                                    .frame(width: 24, height: 24)
                                            }
                                            .padding(.trailing, 23)
                                            .sheet(isPresented: $travelListVM.isShowingEditSheet) {
                                                if let travel = travelListVM.selectedTravel {
                                                    EditTravelSheetView(
                                                        travelListVM: travelListVM,
                                                        travel: travel
                                                    )
                                                    .presentationDetents([.height(250)])
                                                }
                                            }
                                            .navigationDestination(isPresented: $travelListVM.isPresentedDateView) {
                                                DateManagementView(
                                                    travel: travel,
                                                    paymentDates: [],
                                                    entryViewtype: .list
                                                )
                                                .environmentObject(travelDetailStore)
                                            }
                                            .navigationDestination(isPresented: $travelListVM.isPresentedMemeberView) {
                                                if let travel = travelListVM.selectedTravel {
                                                    MemberManagementView(
                                                        travel: travel,
                                                        entryViewType: .list
                                                    )
                                                    .environmentObject(travelDetailStore)
                                                }
                                            }
                                            .navigationDestination(isPresented: $travelListVM.isPresentedSpendingView) {
                                                SettledAccountView(entryViewtype: .list)
                                                    .environmentObject(travelDetailStore)
                                            }
                                        }
                                        .frame(maxWidth: .infinity)
                                        .frame(height: 94)
                                        .background(Color.gray1000.cornerRadius(12))
                                    }
                                    .padding(.top, 12)
                                    
                                } //MARK: LIST
                                .padding(.horizontal, 12)
                            }
                            
                        } //MARK: else
                        
                        
                    }
                } //MARK: SCROLLVIEW
                //                }
                Divider().padding(0)
            } //MARK: VSTACK
            
        } //MARK: ZSTACK
        .navigationDestination(isPresented: $tabViewStore.isPresentedDetail) {
            if let travel = tabViewStore.seletedTravel {
                DetailMainView(travel: travel)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Image(.mainBillBuddy)
                    .resizable()
                    .frame(width: 116, height: 23)
            }
            
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    tabViewStore.pushNotificationListView()
                } label: {
                    if notificationStore.hasUnReadNoti {
                        Image(.redDotRingBell)
                            .resizable()
                            .frame(width: 24, height: 24)
                    }
                    else {
                        Image("ringing-bell-notification-3")
                            .resizable()
                            .frame(width: 24, height: 24)
                    }
                }
            }
        }
        .navigationDestination(isPresented: $tabViewStore.isPresentedNotiList) {
            NotificationListView()
        }
        .overlay(
            Rectangle()
                .fill(Color.systemBlack.opacity(travelListVM.isShowingEditSheet ? 0.6 : 0)).edgesIgnoringSafeArea(.all)
                .onTapGesture {
                    travelListVM.isShowingEditSheet = false
                }
        )
        .overlay(
            Rectangle()
                .fill(Color.systemBlack.opacity(floatingButtonMenuStore.isDimmedBackground ? 0.6 : 0)).edgesIgnoringSafeArea(.all)
                .onTapGesture {
                    floatingButtonMenuStore.isDimmedBackground = false
                    floatingButtonMenuStore.closeMenu()
                }
        )
        .overlay(
            AddTravelButtonView(floatingButtonMenuStore: floatingButtonMenuStore)
                .onTapGesture {
                    floatingButtonMenuStore.isDimmedBackground = true
                }
        )
        
        .toolbar(tabBarVisibilityStore.visibility, for: .tabBar)
        .onAppear {
            tabBarVisibilityStore.showTabBar()
            if let isPremium = userService.currentUser?.isPremium {
                if !isPremium {
                    nativeAdViewModel.refreshAd()
                }
            }
            if !AuthService.shared.userUid.isEmpty {
                if notificationStore.didFetched == false {
                    notificationStore.getUserUid()
                }
            }
            if !travelListVM.isFetchedFirst {
                travelListVM.fetchAll { travels in
                    travelListVM.filterTravel()
                }
            }
        }
        .onDisappear {
            floatingButtonMenuStore.isDimmedBackground = false
            floatingButtonMenuStore.closeMenu()
        }
        
    } //MARK: BODY
    
}

extension TravelListView {
    var travelFilterButton: some View {
        HStack(spacing: 0) {
            ForEach(TravelFilter.allCases, id: \.rawValue) { filter in
                Button {
                    travelListVM.selectedFilter = filter
                    travelListVM.filterTravel()
                } label: {
                    VStack {
                        Text(filter.title)
                            .padding(.top, 25)
                            .font(Font.body02)
                            .fontWeight(travelListVM.selectedFilter == filter ? .bold : .regular)
                            .foregroundColor(travelListVM.selectedFilter == filter ? .myPrimary : .gray500)
                        
                        if filter == travelListVM.selectedFilter {
                            Capsule()
                                .foregroundColor(Color.myPrimary)
                                .frame(width: 100, height: 3)
                            //                            .matchedGeometryEffect(id: "filter", in: animation)
                        } else {
                            Capsule()
                                .foregroundColor(.gray100)
                                .frame(width: 100, height: 3)
                        }
                    }
                }
                .buttonStyle(.plain)

            }
        }
    }
    
    var progressView: some View {
        VStack(spacing: 0) {
            
            ForEach(0..<3) { _ in
                HStack {
                    VStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 12)
                            .frame(width: 60, height: 24)
                            .foregroundColor(.gray200)
                            .padding(.bottom, 4)
                        
                        RoundedRectangle(cornerRadius: 12)
                            .frame(width: 108, height: 20)
                            .foregroundColor(.gray200)
                    }
                    .padding(.leading, 26)
                    
                    Spacer()
                }
                .frame(maxWidth: .infinity)
                .frame(height: 94)
                .background(Color.gray050.cornerRadius(12))
            }
            .padding(.top, 16)
            
            HStack {
                Spacer()
                ProgressView()
                    .frame(width: 30, height: 30)
                Spacer()
            }
            .padding(.top, 19)
            
        }
        .padding(.horizontal, 16)
    }
}
//#Preview {
//    NavigationStack {
//        TravelListView(floatingButtonMenuStore: FloatingButtonMenuStore())
//            .environmentObject(UserTravelStore())
//            .environmentObject(tabBarVisibilityStore())
//            .environmentObject(NotificationStore())
//            .environmentObject(UserService.shared)
//            .environmentObject(NativeAdViewModel())
//    }
//}


