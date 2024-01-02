//
//  PaymentManageView.swift
//  BillBuddy
//
//  Created by 김유진 on 10/17/23.
//

import SwiftUI

struct PaymentManageView: View {
    
    @Environment(\.dismiss) private var dismiss
    
    @StateObject var locationManager = LocationManager()
    @EnvironmentObject private var settlementExpensesStore: SettlementExpensesStore
    @EnvironmentObject private var tabBarVisivilyStore: TabBarVisivilyStore
    @EnvironmentObject private var paymentStore: PaymentService
    @EnvironmentObject private var userTravelStore: UserTravelStore
    @EnvironmentObject private var notificationStore: NotificationStore
    
    @FocusState private var focusedField: PaymentFocusField?
    
    @StateObject private var paymentManageVM: PaymentManageViewModel
    
    init(mode: PaymentManageMode, payment: Payment?, travelCalculation: TravelCalculation) {
        _paymentManageVM = StateObject(wrappedValue: PaymentManageViewModel(mode: mode, payment: payment, travelCalculation: travelCalculation))
    }
    
    init(mode: PaymentManageMode, travelCalculation: TravelCalculation) {
        _paymentManageVM = StateObject(wrappedValue: PaymentManageViewModel(mode: mode, payment: nil, travelCalculation: travelCalculation))
    }
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 0) {
                    if paymentManageVM.mode == .mainAdd {
                        // 메인에서 바로 지출 추가하기로 들어가면, travel을 선택해야함
                        selectTravelSection
                    }
                    fillInPaymentInfoViewSection
                    
                    mapViewSection
                }
            }
            .background(Color.gray100)
            
            underButton
        }
        .toolbar(tabBarVisivilyStore.visivility, for: .tabBar)
        .toolbar(content: {
            ToolbarItem(placement: .topBarLeading) {
                Button(action: {
                    dismiss()
                }, label: {
                    Image("arrow_back")
                        .resizable()
                        .frame(width: 24, height: 24)
                })
            }
            ToolbarItem(placement: .principal) {
                Text(paymentManageVM.navigationTitleString)
                    .font(.title05)
            }
        })
        .onAppear {
            tabBarVisivilyStore.hideTabBar()
            paymentManageVM.setTitleString(userTravelStore: userTravelStore)
        }
        .navigationBarBackButtonHidden()
        .navigationBarTitleDisplayMode(.inline)
        
    }
}

extension PaymentManageView {
    // MARK: SubView Section
    var selectTravelSection: some View {
        Group {
            HStack {
                Text("여행")
                    .font(.body02)
                
                Spacer()
                Button(action: {
                    paymentManageVM.isShowingSelectTripSheet = true
                }, label: {
                    
                    Text(paymentManageVM.travelCalculation.travelTitle)
                        .font(.body04)
                        .foregroundStyle(Color.gray600)
                    
                })
            }
            .padding(.leading, 16)
            .padding(.top, 16)
            .padding(.bottom, 16)
            .padding(.trailing, 16)
            
            .sheet(isPresented: $paymentManageVM.isShowingSelectTripSheet, content: {
                VStack {
                    ForEach(userTravelStore.travels) { travel in
                        HStack {
                            Button(action: {
                                paymentManageVM.setTravel(travel: travel)
                            }, label: {
                                Text(travel.travelTitle)
                                    .font(.body01)
                            })
                            .buttonStyle(.plain)
                            .padding(.bottom, 32)
                            
                            Spacer()
                        }
                    }
                }
                .padding(.top, 48)
                .padding(.leading, 30)
                .presentationDetents([.fraction(0.4)])
            })
        }
        .onAppear {
            paymentManageVM.setTravelAlertOrSheet(userTravelStore: userTravelStore)
        }
        .alert(isPresented: $paymentManageVM.isShowingNoTravelAlert, content: {
            return Alert(title: Text(PaymentAlertText.noTravel),
                         dismissButton: .default(Text("확인"), action: { dismiss()}))
        })
        
        .background {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white)
        }
        .padding(.top, 16)
        .padding(.leading, 16)
        .padding(.trailing, 16)
    }
    
    var fillInPaymentInfoViewSection: some View {
        Section {
            FillInPaymentInfoView(paymentManageVM: paymentManageVM, focusedField: $focusedField)
                .onAppear {
                    paymentManageVM.setInitialValue()
                }
        }
    }
    
    var mapViewSection: some View {
        Section {
            AddPaymentMapView(locationManager: locationManager, searchAddress: $paymentManageVM.searchAddress)
                .onAppear {
                    paymentManageVM.setAddress()
                }
            Spacer()
        }
        .background {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white)
        }
        .padding(.leading, 16)
        .padding(.top, 16)
        .padding(.trailing, 16)
        .padding(.bottom, 38)
    }
    
    var underButton: some View {
        Button(action: {
            focusedField = paymentManageVM.pressCompleteButton()
        }, label: {
            switch(paymentManageVM.mode) {
            case .add:
                PaymentButtonView(scale: .big, text: "추가하기")
            case .mainAdd:
                PaymentButtonView(scale: .big, text: "추가하기")
            case .edit:
                PaymentButtonView(scale: .big, text: "수정하기")
            }
        })
        .alert(isPresented: $paymentManageVM.isShowingAlert, content: {
            if paymentManageVM.mode == .mainAdd && paymentManageVM.travelCalculation.travelTitle.isEmpty {
                return Alert(title: Text(PaymentAlertText.selectTravel))
            }
            else if paymentManageVM.selectedCategory == nil {
                return Alert(title: Text(PaymentAlertText.selectCategory))
            }
            else if paymentManageVM.expandDetails.isEmpty {
                focusedField = .content
                return Alert(title: Text(PaymentAlertText.typeContent))
            }
            else if paymentManageVM.priceString.isEmpty {
                focusedField = .price
                return Alert(title: Text(PaymentAlertText.price))
            }
            else if paymentManageVM.participants.isEmpty {
                focusedField = .none
                return Alert(title: Text(PaymentAlertText.selectMember), dismissButton: .default(Text("인원 추가하기"), action: {
                    hideKeyboard()
                    paymentManageVM.isShowingMemberSheet = true
                }))
            }
            else {
                switch(paymentManageVM.mode) {
                case .add:
                    return Alert(title: Text(PaymentAlertText.add), primaryButton: .cancel(Text("아니오")), secondaryButton: .default(Text("네"), action: {
                        paymentManageVM.addPayment(paymentStore: paymentStore, settlementExpensesStore: settlementExpensesStore, locationManager: locationManager, notificationStore: notificationStore)
                        dismiss()
                    }))
                case .mainAdd:
                    return Alert(title: Text(PaymentAlertText.add), primaryButton: .cancel(Text("아니오")), secondaryButton: .default(Text("네"), action: {
                        paymentManageVM.mainAddPayment(paymentStore: paymentStore, settlementExpensesStore: settlementExpensesStore, locationManager: locationManager, notificationStore: notificationStore, userTravelStore: userTravelStore)
                        dismiss()
                    }))
                case .edit:
                    return Alert(title: Text(PaymentAlertText.edit), primaryButton: .cancel(Text("아니오")), secondaryButton: .default(Text("네"), action: {
                        paymentManageVM.editPayment(paymentStore: paymentStore, settlementExpensesStore: settlementExpensesStore, locationManager: locationManager, notificationStore: notificationStore)
                        dismiss()
                    }))
                }
            }
        })
        .background(Color.myPrimary)
    }
}

extension PaymentManageView {
    // MARK: Function Section
    
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
