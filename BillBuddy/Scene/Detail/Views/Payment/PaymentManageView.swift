//
//  PaymentManageView.swift
//  BillBuddy
//
//  Created by 김유진 on 10/17/23.
//

import SwiftUI

struct PaymentManageView: View {
    
    enum Mode {
        case mainAdd
        case add
        case edit
    }
    
    @Environment(\.dismiss) private var dismiss
    
    var mode: Mode
    @State var payment: Payment?
    @State var travelCalculation: TravelCalculation
    
    @StateObject var locationManager = LocationManager()
    @EnvironmentObject private var settlementExpensesStore: SettlementExpensesStore
    @EnvironmentObject private var tabBarVisivilyStore: TabBarVisivilyStore
    @EnvironmentObject private var paymentStore: PaymentService
    @EnvironmentObject private var userTravelStore: UserTravelStore
    @EnvironmentObject private var notificationStore: NotificationStore
    
    @FocusState private var focusedField: PaymentFocusField?
    
    @StateObject private var paymentManageVM: PaymentManageViewModel = PaymentManageViewModel()
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 0) {
                    if mode == .mainAdd {
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
            if mode == .edit {
                paymentManageVM.navigationTitleString = "지출 내역 수정"
            }
            
            if mode == .mainAdd{
                paymentManageVM.isShowingSelectTripSheet = true
                if let first =  userTravelStore.travels.first {
                    travelCalculation = first
                }
            }
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
                    
                    Text(travelCalculation.travelTitle)
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
                                travelCalculation = travel
                                paymentManageVM.paymentDate = travel.startDate.toDate()
                                paymentManageVM.isShowingSelectTripSheet = false
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
            if userTravelStore.travels.isEmpty {
                paymentManageVM.isShowingNoTravelAlert = true
            }
            else {
                paymentManageVM.isShowingSelectTripSheet = true
            }
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
            switch mode {
            case .add:
                FillInPaymentInfoView(travelCalculation: $travelCalculation, expandDetails: $paymentManageVM.expandDetails, priceString: $paymentManageVM.priceString, selectedCategory: $paymentManageVM.selectedCategory, paymentDate: $paymentManageVM.paymentDate, payment: .constant(nil), participants: $paymentManageVM.participants, isShowingMemberSheet: $paymentManageVM.isShowingMemberSheet, focusedField: $focusedField)
                    .onAppear {
                        paymentManageVM.paymentDate = travelCalculation.startDate.toDate()
                    }
            case .edit:
                FillInPaymentInfoView(mode: .edit, travelCalculation: $travelCalculation, expandDetails: $paymentManageVM.expandDetails, priceString: $paymentManageVM.priceString, selectedCategory: $paymentManageVM.selectedCategory, paymentDate: $paymentManageVM.paymentDate, payment: $payment, participants: $paymentManageVM.participants, isShowingMemberSheet: $paymentManageVM.isShowingMemberSheet, focusedField: $focusedField)
                    .onAppear {
                        if let payment = payment {
                            paymentManageVM.selectedCategory = payment.type
                            paymentManageVM.expandDetails = payment.content
                            paymentManageVM.priceString = String(payment.payment)
                            paymentManageVM.paymentDate = payment.paymentDate.toDate()
                        }
                    }
            case .mainAdd:
                FillInPaymentInfoView(travelCalculation: $travelCalculation, expandDetails: $paymentManageVM.expandDetails, priceString: $paymentManageVM.priceString, selectedCategory: $paymentManageVM.selectedCategory, paymentDate: $paymentManageVM.paymentDate, payment: .constant(nil), participants: $paymentManageVM.participants, isShowingMemberSheet: $paymentManageVM.isShowingMemberSheet, focusedField: $focusedField)
                    .onAppear {
                        paymentManageVM.paymentDate = travelCalculation.startDate.toDate()
                    }
            }
        }
    }
    
    var mapViewSection: some View {
        Section {
            AddPaymentMapView(locationManager: locationManager, searchAddress: $paymentManageVM.searchAddress)
                .onAppear {
                    if let p = payment {
                        paymentManageVM.searchAddress = p.address.address
                    }
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
            if mode == .mainAdd && travelCalculation.travelTitle.isEmpty {
                paymentManageVM.isShowingSelectTripSheet = true
            }
            else if paymentManageVM.selectedCategory == nil {
                focusedField = .type
            }
            else if paymentManageVM.expandDetails.isEmpty {
                focusedField = .content
            }
            else if paymentManageVM.priceString.isEmpty {
                focusedField = .price
            }
            
            paymentManageVM.isShowingAlert = true
            
        }, label: {
            switch(mode) {
            case .add:
                PaymentButtonView(scale: .big, text: "추가하기")
            case .mainAdd:
                PaymentButtonView(scale: .big, text: "추가하기")
            case .edit:
                PaymentButtonView(scale: .big, text: "수정하기")
            }
        })
        .alert(isPresented: $paymentManageVM.isShowingAlert, content: {
            if mode == .mainAdd && travelCalculation.travelTitle.isEmpty {
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
                switch(mode) {
                case .add:
                    return Alert(title: Text(PaymentAlertText.add), primaryButton: .cancel(Text("아니오")), secondaryButton: .default(Text("네"), action: {
                        addPayment()
                        dismiss()
                    }))
                case .mainAdd:
                    return Alert(title: Text(PaymentAlertText.add), primaryButton: .cancel(Text("아니오")), secondaryButton: .default(Text("네"), action: {
                        mainAddPayment()
                        dismiss()
                    }))
                case .edit:
                    return Alert(title: Text(PaymentAlertText.edit), primaryButton: .cancel(Text("아니오")), secondaryButton: .default(Text("네"), action: {
                        editPayment()
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
    func addPayment() {
        let newPayment =
        Payment(type: paymentManageVM.selectedCategory ?? .etc, content: paymentManageVM.expandDetails, payment: Int(paymentManageVM.priceString) ?? 0, address: Payment.Address(address: locationManager.selectedAddress, latitude: locationManager.selectedLatitude, longitude: locationManager.selectedLongitude), participants: paymentManageVM.participants, paymentDate: paymentManageVM.paymentDate.timeIntervalSince1970)
        
        Task {
            await paymentStore.addPayment(newPayment: newPayment)
            settlementExpensesStore.setSettlementExpenses(payments: paymentStore.payments, members: self.travelCalculation.members)
        }
        
        PushNotificationManager.sendPushNotification(toTravel: travelCalculation, title: "\(travelCalculation.travelTitle)여행방", body: "지출이 추가 되었습니다.", senderToken: "senderToken")
        notificationStore.sendNotification(members: travelCalculation.members, notification: UserNotification(type: .travel, content: "\(travelCalculation.travelTitle)여행방에서 확인하지 않은 지출", contentId: "\(URLSchemeBase.scheme.rawValue)://travel?travelId=\(travelCalculation.id)", addDate: Date(), isChecked: false))
    }
    
    func mainAddPayment() {
        let newPayment =
        Payment(type: paymentManageVM.selectedCategory ?? .etc, content: paymentManageVM.expandDetails, payment: Int(paymentManageVM.priceString) ?? 0, address: Payment.Address(address: locationManager.selectedAddress, latitude: locationManager.selectedLatitude, longitude: locationManager.selectedLongitude), participants: paymentManageVM.participants, paymentDate: paymentManageVM.paymentDate.timeIntervalSince1970)
        userTravelStore.addPayment(travelCalculation: travelCalculation, payment: newPayment)
        
        PushNotificationManager.sendPushNotification(toTravel: travelCalculation, title: "\(travelCalculation.travelTitle)여행방", body: "지출이 추가 되었습니다.", senderToken: "senderToken")
        notificationStore.sendNotification(members: travelCalculation.members, notification: UserNotification(type: .travel, content: "\(travelCalculation.travelTitle)여행방에서 확인하지 않은 지출", contentId: "\(URLSchemeBase.scheme.rawValue)://travel?travelId=\(travelCalculation.id)", addDate: Date(), isChecked: false))
    }
    
    func editPayment() {
        if let payment = payment {
            let newPayment = Payment(id: payment.id, type: paymentManageVM.selectedCategory ?? .etc, content: paymentManageVM.expandDetails, payment: Int(paymentManageVM.priceString) ?? 0, address: Payment.Address(address: locationManager.selectedAddress, latitude: locationManager.selectedLatitude, longitude: locationManager.selectedLongitude), participants: paymentManageVM.participants, paymentDate: paymentManageVM.paymentDate.timeIntervalSince1970)
            Task {
                await paymentStore.editPayment(payment: newPayment)
                settlementExpensesStore.setSettlementExpenses(payments: paymentStore.payments, members: self.travelCalculation.members)
            }
        }
    }
    
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
