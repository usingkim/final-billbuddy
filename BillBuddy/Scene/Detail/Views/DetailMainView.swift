//
//  DetailMainView.swift
//  BillBuddy
//
//  Created by 김유진 on 10/9/23.
//

import SwiftUI

struct DetailMainView: View {
    
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var notificationStore: NotificationStore
    @EnvironmentObject private var settlementExpensesStore: SettlementExpensesStore
    @EnvironmentObject private var tabBarVisivilyStore: TabBarVisibilityStore

    @StateObject private var paymentService: PaymentService
    @StateObject private var travelDetailStore: TravelDetailStore
    @StateObject private var locationManager = LocationManager()
    
    @StateObject private var detailMainVM = DetailMainViewModel()
    
    let menus: [String] = ["내역", "지도"]
    
    init(travel: TravelCalculation) {
        _paymentService = StateObject(wrappedValue: PaymentService(travel: travel))
        _travelDetailStore = StateObject(wrappedValue: TravelDetailStore(travel: travel))
    }
    
    
    var body: some View {
        VStack(spacing: 0) {
            sliderSection
            
            Capsule()
                .frame(height: 1)
                .foregroundStyle(Color.gray400)
            
            dateSelectSection
                .frame(height: 52)
            
            if detailMainVM.selectMenu == "내역" {
                ZStack {
                    PaymentMainView(detailMainVM: detailMainVM)
                        .environmentObject(travelDetailStore)
                        .environmentObject(paymentService)
                    
                    if travelDetailStore.isChangedTravel &&
                        paymentService.updateContentDate != travelDetailStore.travel.updateContentDate &&
                        !paymentService.isFetchingList
                    {
                        
                        Button {
                            detailMainVM.fetchPaymentAndSettledAccount(paymentStore: paymentService, travelDetailStore: travelDetailStore, settlementExpensesStore: settlementExpensesStore)
                            travelDetailStore.isChangedTravel = false
                        } label: {
                            HStack(spacing: 8) {
                                Image(.info)
                                    .resizable()
                                    .frame(width: 24, height: 24)
                                Text("새로운 변경사항이 있어요")
                                    .font(.body01)
                                Image(.chevronRight)
                                    .resizable()
                                    .frame(width: 24, height: 24)
                            }
                            .padding(.leading, 12)
                            .padding(.trailing, 12)
                            .padding(.top, 10)
                            .padding(.bottom, 10)
                        }
                        .frame(height: 44)
                        .background {
                            RoundedRectangle(cornerRadius: 22.5)
                                .stroke(Color.myPrimary, style: StrokeStyle(lineWidth: 1))
                        }
                        .background(Color.white)
                        .padding(.top, 300)
                        
                        
                    }
                    
                }
            }
            else if detailMainVM.selectMenu == "지도" {
                MapMainView(detailMainVM: detailMainVM)
                    .environmentObject(locationManager)
                    .environmentObject(paymentService)
            }
        }
        
        .onAppear {
            tabBarVisivilyStore.hideTabBar()
            if detailMainVM.selectedDate == 0 {
                Task {
                    if travelDetailStore.isFirstFetch {
                        travelDetailStore.setTravel()

                        travelDetailStore.checkAndResaveToken()
                        detailMainVM.fetchPaymentAndSettledAccount(paymentStore: paymentService, travelDetailStore: travelDetailStore, settlementExpensesStore: settlementExpensesStore)
                        travelDetailStore.isFirstFetch = false
                        
                    }
                }
                travelDetailStore.listenTravelDate()
            }
        }
        .onDisappear {
            travelDetailStore.stoplistening()
        }
        .navigationBarBackButtonHidden()
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(tabBarVisivilyStore.visibility, for: .tabBar)
        .toolbar(content: {
            ToolbarItem(placement: .topBarLeading) {
                Button(action: {
                    dismiss()
                }, label: {
                    Image(.arrowBack)
                        .resizable()
                        .frame(width: 24, height: 24)
                })
            }
            ToolbarItem(placement: .topBarTrailing) {
                NavigationLink {
                    NotificationListView()
                } label: {
                    if notificationStore.hasUnReadNoti {
                        Image(.redDotRingBell)
                            .resizable()
                            .frame(width: 24, height: 24)
                    }
                    else {
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
            ToolbarItem(placement: .topBarTrailing) {
                NavigationLink {
                    MoreView(travel: travelDetailStore.travel)
                        .environmentObject(travelDetailStore)
                        .environmentObject(paymentService)
                } label: {
                    Image("steps-1 3")
                        .resizable()
                        .frame(width: 24, height: 24)
                }
            }
            ToolbarItem(placement: .principal) {
                Text(travelDetailStore.travel.travelTitle)
                    .font(.title05)
            }
            
        })
        
        
        
    }
    
    var sliderSection: some View {
        HStack(spacing: 12, content: {
            ForEach(menus, id: \.self) { menu in
                Button(action: {
                    withAnimation(Animation.default) {
                        detailMainVM.selectMenu = menu
                    }
                }, label: {
                    VStack(spacing: 0) {
                        if detailMainVM.selectMenu == menu {
                            Text(menu)
                                .frame(width: 160, height: 41)
                                .font(.body01)
                                .foregroundStyle(Color.myPrimary)
                            Capsule()
                                .frame(width: 160, height: 3)
                                .foregroundStyle(Color.myPrimary)
                        }
                        else {
                            Text(menu)
                                .frame(width: 160, height: 41)
                                .font(.body01)
                                .foregroundStyle(Color.gray400)
                        }
                    }
                })
                
            }
        })
        
    }
    
    
    var dateSelectSection: some View {
        
        HStack {
            Button {
                detailMainVM.isShowingDateSheet = true
            } label: {
                
                if detailMainVM.selectedDate == 0 {
                    Text("전체")
                        .font(.body01)
                        .foregroundStyle(.black)
                    Image("expand_more")
                        .resizable()
                        .frame(width: 24, height: 24)
                }
                
                else {
                    Text(detailMainVM.selectedDate.toDate().dateWeekYear)
                        .font(.body01)
                        .foregroundStyle(.black)
                    Text("\(detailMainVM.selectedDate.howManyDaysFromStartDate(startDate: travelDetailStore.travel.startDate))일차")
                        .font(.body03)
                        .foregroundStyle(Color.gray600)
                    Image("expand_more")
                        .renderingMode(.template)
                        .resizable()
                        .frame(width: 24, height: 24)
                        .foregroundStyle(Color.gray600)
                }
            }
            .padding(.leading, 16)
            .padding(.bottom, 13)
            .padding(.top, 15)
            
            
            Spacer()
        }
        
        .sheet(isPresented: $detailMainVM.isShowingDateSheet, content: {
            DateSheet(locationManager: locationManager, detailMainVM: detailMainVM, startDate: travelDetailStore.travel.startDate, endDate: travelDetailStore.travel.endDate)
                .presentationDetents([.fraction(0.4)])
        })
        
        
    }
}

//#Preview {
//    let travel = TravelCalculation(hostId: "", travelTitle: "서울 여행", managerId: "", startDate: <#T##Double#>, endDate: <#T##Double#>, updateContentDate: <#T##Double#>, members: <#T##[TravelCalculation.Member]#>)
//    DetailMainView(paymentStore: PaymentStore(travel: <#T##TravelCalculation#>), travelDetailStore: TravelDetailStore(travel: <#T##TravelCalculation#>))
//}
