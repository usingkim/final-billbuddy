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
    
    @State var mode: Mode
    
    @State var payment: Payment?
    
    @StateObject var locationManager = LocationManager()
    @EnvironmentObject private var settlementExpensesStore: SettlementExpensesStore
    @EnvironmentObject private var tabBarVisivilyStore: TabBarVisivilyStore
    @EnvironmentObject private var paymentStore: PaymentStore
    @EnvironmentObject private var userTravelStore: UserTravelStore
    @EnvironmentObject private var notificationStore: NotificationStore
    
    @State var travelCalculation: TravelCalculation
    
    @State private var expandDetails: String = ""
    @State private var priceString: String = ""
    @State private var searchAddress: String = ""
    @State private var selectedCategory: Payment.PaymentType?
    @State private var paymentDate: Date = Date.now
    @State private var isShowingSelectTripSheet: Bool = false
    @State private var isShowingNoTravelAlert: Bool = false
    @State private var navigationTitleString: String = "지출 내역 추가"
    @State private var isShowingAlert: Bool = false
    @State private var participants: [Payment.Participant] = []
    
    @FocusState private var focusedField: PaymentFocusField?
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 0) {
                    if mode == .mainAdd {
                        selectTravelSection
                    }
                    subPaymentViewSection
                        .padding(.bottom, 16)
                    
                    mapViewSection
                }
                .background(Color.gray100)
            }
            button
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
                Text(navigationTitleString)
                    .font(.title05)
            }
        })
        .onAppear {
            tabBarVisivilyStore.hideTabBar()
            if mode == .edit {
                navigationTitleString = "지출 내역 수정"
            }
            
            if mode == .mainAdd{
                isShowingSelectTripSheet = true
                if let first =  userTravelStore.travels.first {
                    travelCalculation = first
                }
            }
        }
        .navigationBarBackButtonHidden()
        .navigationBarTitleDisplayMode(.inline)
        
    }
    
    var selectTravelSection: some View {
        Group {
            HStack {
                Text("여행")
                    .font(.body02)
                
                Spacer()
                Button(action: {
                    isShowingSelectTripSheet = true
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
            
            .sheet(isPresented: $isShowingSelectTripSheet, content: {
                VStack {
                    ForEach(userTravelStore.travels) { travel in
                        HStack {
                            Button(action: {
                                travelCalculation = travel
                                paymentDate = travel.startDate.toDate()
                                isShowingSelectTripSheet = false
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
                isShowingNoTravelAlert = true
            }
            else {
                isShowingSelectTripSheet = true
            }
        }
        .alert(isPresented: $isShowingNoTravelAlert, content: {
            
            return Alert(title: Text("생성된 여행이 없습니다"),
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
    
    var subPaymentViewSection: some View {
        Section {
            switch mode {
            case .add:
                FillInPaymentInfoView(travelCalculation: $travelCalculation, expandDetails: $expandDetails, priceString: $priceString, selectedCategory: $selectedCategory, paymentDate: $paymentDate, payment: .constant(nil), participants: $participants, focusedField: $focusedField)
                    .onAppear {
                        paymentDate = travelCalculation.startDate.toDate()
                    }
            case .edit:
                FillInPaymentInfoView(mode: .edit, travelCalculation: $travelCalculation, expandDetails: $expandDetails, priceString: $priceString, selectedCategory: $selectedCategory, paymentDate: $paymentDate, payment: $payment, participants: $participants, focusedField: $focusedField)
                    .onAppear {
                        if let payment = payment {
                            selectedCategory = payment.type
                            expandDetails = payment.content
                            priceString = String(payment.payment)
                            paymentDate = payment.paymentDate.toDate()
                        }
                    }
            case .mainAdd:
                FillInPaymentInfoView(travelCalculation: $travelCalculation, expandDetails: $expandDetails, priceString: $priceString, selectedCategory: $selectedCategory, paymentDate: $paymentDate, payment: .constant(nil), participants: $participants, focusedField: $focusedField)
                    .onAppear {
                        paymentDate = travelCalculation.startDate.toDate()
                    }
            }
        }
    }
    
    var mapViewSection: some View {
        Section {
            switch(mode) {
            case .edit:
                HStack {
                    AddPaymentMapView(locationManager: locationManager, searchAddress: $searchAddress)
                        .onAppear {
                            if let p = payment {
                                searchAddress = p.address.address
                            }
                        }
                    Spacer()
                }
            case .mainAdd:
                AddPaymentMapView(locationManager: locationManager, searchAddress: $searchAddress)
                Spacer()
            case .add:
                AddPaymentMapView(locationManager: locationManager, searchAddress: $searchAddress)
                Spacer()
            }
        }
        .background {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white)
        }
        .padding(.leading, 16)
        .padding(.trailing, 16)
        .padding(.bottom, 38)
        
    }
    
    func buttonText(text: String) -> Text {
        return Text(text)
            .font(.title05)
            .foregroundColor(.white)
    }
    
    var buttonLabel: some View {
        HStack {
            Spacer()
            
            switch(mode) {
            case .add:
                buttonText(text: "추가하기")
            case .mainAdd:
                buttonText(text: "추가하기")
            case .edit:
                buttonText(text: "수정하기")
            }
            
            Spacer()
        }
        .padding(.top, 24)
        .padding(.bottom, 24)
    }
    
    var button: some View {
        Button(action: {
            if mode == .mainAdd && travelCalculation.travelTitle.isEmpty {
                isShowingSelectTripSheet = true
            }
            else if selectedCategory == nil {
                focusedField = .type
            }
            else if expandDetails.isEmpty {
                focusedField = .content
            }
            else if priceString.isEmpty {
                focusedField = .price
            }
            
            isShowingAlert = true
            
        }, label: {
            buttonLabel
        })
        .alert(isPresented: $isShowingAlert, content: {
            if mode == .mainAdd && travelCalculation.travelTitle.isEmpty {
                return Alert(title: Text("여행을 선택해주세요"))
            }
            else if selectedCategory == nil {
                return Alert(title: Text("분류를 선택해주세요"))
            }
            else if expandDetails.isEmpty {
                return Alert(title: Text("내용을 입력해주세요"))
            }
            else if participants.isEmpty {
                return Alert(title: Text("이 지출에 포함되는 인원을 선택해주세요"))
            }
            else if priceString.isEmpty {
                return Alert(title: Text("쓴 돈을 입력해주세요"))
            }
            else {
                switch(mode) {
                case .add:
                    return Alert(title: Text("추가하시겠습니까?"), primaryButton: .cancel(Text("아니오")), secondaryButton: .default(Text("네"), action: {
                        addPayment()
                        PushNotificationManager.sendPushNotification(toTravel: travelCalculation, title: "\(travelCalculation.travelTitle)여행방", body: "지출이 추가 되었습니다.", senderToken: "senderToken")
                        NotificationStore().sendNotification(members: travelCalculation.members, notification: UserNotification(type: .travel, content: "지출이 추가되었습니다.", contentId: "\(URLSchemeBase.scheme.rawValue)://travel?travelId=\(travelCalculation.id)", addDate: Date(), isChecked: false))
                        dismiss()
                    }))
                case .mainAdd:
                    return Alert(title: Text("추가하시겠습니까?"), primaryButton: .cancel(Text("아니오")), secondaryButton: .default(Text("네"), action: {
                        mainAddPayment()
                        PushNotificationManager.sendPushNotification(toTravel: travelCalculation, title: "\(travelCalculation.travelTitle)여행방", body: "지출이 추가 되었습니다.", senderToken: "senderToken")
                        NotificationStore().sendNotification(members: travelCalculation.members, notification: UserNotification(type: .travel, content: "지출이 추가되었습니다.", contentId: "\(URLSchemeBase.scheme.rawValue)://travel?travelId=\(travelCalculation.id)", addDate: Date(), isChecked: false))
                        dismiss()
                    }))
                case .edit:
                    return Alert(title: Text("수정하시겠습니까?"), primaryButton: .cancel(Text("아니오")), secondaryButton: .default(Text("네"), action: {
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
    
    func addPayment() {
//        var participants: [Payment.Participant] = []
//        
//        for m in members {
//            participants.append(Payment.Participant(memberId: m.id, advanceAmount: 0, seperateAmount: 0, memo: ""))
//        }
        
        let newPayment =
        Payment(type: selectedCategory ?? .etc, content: expandDetails, payment: Int(priceString) ?? 0, address: Payment.Address(address: locationManager.selectedAddress, latitude: locationManager.selectedLatitude, longitude: locationManager.selectedLongitude), participants: participants, paymentDate: paymentDate.timeIntervalSince1970)
        
        //
        Task {
            await paymentStore.addPayment(newPayment: newPayment)
            settlementExpensesStore.setSettlementExpenses(payments: paymentStore.payments, members: self.travelCalculation.members)
        }
        // TODO: ADD 하고 나면 날짜랑 카테고리 전체로 변경되도록 변경하기
    }
    
    func mainAddPayment() {
//        var participants: [Payment.Participant] = []
        
//        for m in members {
//            participants.append(Payment.Participant(memberId: m.id, advanceAmount: 0, seperateAmount: 0, memo: ""))
//        }
        
        let newPayment =
        Payment(type: selectedCategory ?? .etc, content: expandDetails, payment: Int(priceString) ?? 0, address: Payment.Address(address: locationManager.selectedAddress, latitude: locationManager.selectedLatitude, longitude: locationManager.selectedLongitude), participants: participants, paymentDate: paymentDate.timeIntervalSince1970)
        userTravelStore.addPayment(travelCalculation: travelCalculation, payment: newPayment)
    }
    
    func editPayment() {
        if let payment = payment {
            let newPayment = Payment(id: payment.id, type: selectedCategory ?? .etc, content: expandDetails, payment: Int(priceString) ?? 0, address: Payment.Address(address: locationManager.selectedAddress, latitude: locationManager.selectedLatitude, longitude: locationManager.selectedLongitude), participants: participants, paymentDate: paymentDate.timeIntervalSince1970)
            Task {
                await paymentStore.editPayment(payment: newPayment)
                settlementExpensesStore.setSettlementExpenses(payments: paymentStore.payments, members: self.travelCalculation.members)
            }
        }
    }
}
//
//#Preview {
//    PaymentManageView(mode: .mainAdd, travelCalculation: TravelCalculation(hostId: "", travelTitle: "", managerId: "", startDate: 0, endDate: 0, updateContentDate: 0, members: [TravelCalculation.Member(name: "인원1", advancePayment: 0, payment: 0)]))
//        .environmentObject(TabBarVisivilyStore())
//}
