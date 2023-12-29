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
    @EnvironmentObject private var tabBarVisivilyStore: TabBarVisivilyStore
    
    @StateObject var travelDetailStore: TravelDetailStore
    @StateObject var paymentStore: PaymentStore
    @StateObject private var locationManager = LocationManager()
    
    @StateObject private var detailMainViewModel: DetailMainViewModel
    
    let menus: [String] = ["내역", "지도"]
    
    init(travel: TravelCalculation) {
        _detailMainViewModel = StateObject(wrappedValue: DetailMainViewModel(travel: travel))
        _travelDetailStore = StateObject(wrappedValue: TravelDetailStore(travel: travel))
        _paymentStore = StateObject(wrappedValue: PaymentStore(travel: travel))
    }
    
    func fetchPaymentAndSettledAccount(edit: Bool) {
        Task {
            if edit {
                travelDetailStore.saveUpdateDate()
            }
            await detailMainViewModel.fetchAll()
//            settlementExpensesStore.setSettlementExpenses(payments: paymentStore.payments, members: travelDetailStore.travel.members)
            detailMainViewModel.selectedDate = 0
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            sliderSection
            
            Capsule()
                .frame(height: 1)
                .foregroundStyle(Color.gray400)
            
            dateSelectSection
                .frame(height: 52)
            
            if detailMainViewModel.selection == "내역" {
                ZStack {
                    PaymentMainView(selectedDate: Binding<Double>(
                        get: { detailMainViewModel.selectedDate },
                        set: { detailMainViewModel.selectedDate = $0 }
                    ))
                        .environmentObject(paymentStore)
                        .environmentObject(travelDetailStore)
                    
                    if travelDetailStore.isChangedTravel &&
                        detailMainViewModel.updateContentDate != travelDetailStore.travel.updateContentDate &&
                        !detailMainViewModel.isFetchingList
                    {
                        
                        Button {
                            Task {
                                fetchPaymentAndSettledAccount(edit: false)
                                travelDetailStore.isChangedTravel = false
                            }
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
            else if detailMainViewModel.selection == "지도" {
                MapMainView(locationManager: locationManager, travelDetailStore: travelDetailStore, selectedDate: Binding<Double>(
                    get: { detailMainViewModel.selectedDate },
                    set: { detailMainViewModel.selectedDate = $0 }
                ))
            }
        }
        .onChange(of: detailMainViewModel.selectedDate, perform: { date in
            detailMainViewModel.changeDate(newDate: date)
        })
        .onAppear {
            tabBarVisivilyStore.hideTabBar()
            if detailMainViewModel.selectedDate == 0 {
                Task {
                    if travelDetailStore.isFirstFetch {
                        travelDetailStore.setTravel()

                        travelDetailStore.checkAndResaveToken()
                        fetchPaymentAndSettledAccount(edit: false)
                        travelDetailStore.isFirstFetch = false
                        
                    }
                }
                travelDetailStore.listenTravelDate()
            } else {
                detailMainViewModel.filterDate(date: detailMainViewModel.selectedDate)
            }
        }
        .onDisappear {
            travelDetailStore.stoplistening()
        }
        .navigationBarBackButtonHidden()
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(tabBarVisivilyStore.visivility, for: .tabBar)
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
                        detailMainViewModel.selection = menu
                    }
                }, label: {
                    VStack(spacing: 0) {
                        if detailMainViewModel.selection == menu {
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
                detailMainViewModel.isShowingDateSheet = true
            } label: {
                
                if detailMainViewModel.selectedDate == 0 {
                    Text("전체")
                        .font(.body01)
                        .foregroundStyle(.black)
                    Image("expand_more")
                        .resizable()
                        .frame(width: 24, height: 24)
                }
                
                else {
                    Text(detailMainViewModel.selectedDate.toDate().dateWeekYear)
                        .font(.body01)
                        .foregroundStyle(.black)
                    Text("\(detailMainViewModel.selectedDate.howManyDaysFromStartDate(startDate: travelDetailStore.travel.startDate))일차")
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
        
        .sheet(isPresented: Binding<Bool>(
            get: { detailMainViewModel.isShowingDateSheet },
            set: { detailMainViewModel.isShowingDateSheet = $0 }
        ), content: {
            DateSheet(locationManager: locationManager, detailMainViewModel: detailMainViewModel, isShowingDateSheet: Binding<Bool>(
                get: { detailMainViewModel.isShowingDateSheet },
                set: { detailMainViewModel.isShowingDateSheet = $0 }
            ), selectedDate: Binding<Double>(
                get: { detailMainViewModel.selectedDate },
                set: { detailMainViewModel.selectedDate = $0 }
            ), startDate: travelDetailStore.travel.startDate, endDate: travelDetailStore.travel.endDate)
                .presentationDetents([.fraction(0.4)])
        })
        
        
    }
}

//#Preview {
//    let travel = TravelCalculation(hostId: "", travelTitle: "서울 여행", managerId: "", startDate: <#T##Double#>, endDate: <#T##Double#>, updateContentDate: <#T##Double#>, members: <#T##[TravelCalculation.Member]#>)
//    DetailMainView(paymentStore: PaymentStore(travel: <#T##TravelCalculation#>), travelDetailStore: TravelDetailStore(travel: <#T##TravelCalculation#>))
//}
