//
//  PaymentManageViewModel.swift
//  BillBuddy
//
//  Created by 김유진 on 1/2/24.
//

import Foundation
import Combine

@MainActor
final class PaymentManageViewModel: ObservableObject {
    var mode: PaymentManageMode
    
    var paymentService: PaymentService
    
    private var cancellables: Set<AnyCancellable> = []
    
    @Published var payment: Payment?
    @Published var travelCalculation: TravelCalculation
    
    @Published var expandDetails: String = ""
    @Published var priceString: String = ""
    @Published var searchAddress: String = ""
    @Published var selectedCategory: Payment.PaymentType?
    @Published var paymentDate: Date = Date.now
    @Published var isShowingSelectTripSheet: Bool = false
    @Published var isShowingNoTravelAlert: Bool = false
    @Published var navigationTitleString: String = "지출 내역 추가"
    @Published var isShowingAlert: Bool = false
    @Published var participants: [Payment.Participant] = []
    @Published var isShowingMemberSheet: Bool = false
    
    @Published var isShowingAddress: Bool = false
    @Published var isShowingMapView: Bool = false
    @Published var isShowingDatePicker: Bool = false
    @Published var isShowingTimePicker: Bool = false
    @Published var paymentType: Int = 0 // 0: 1/n, 1: 개별
    @Published var selectedMember: TravelCalculation.Member = TravelCalculation.Member(name: "", advancePayment: 0, payment: 0)
    @Published var members: [TravelCalculation.Member] = []
    
    @Published var isShowingDescription: Bool = false
    @Published var isShowingPersonalMemberSheet: Bool = false
    @Published var paidButton: Bool = false
    @Published var personalButton: Bool = false
    @Published var tempMembers: [TravelCalculation.Member] = []
    
    @Published var advanceAmountString: String = ""
    @Published var seperateAmountString: String = ""
    @Published var personalMemo: String = ""
    @Published var seperate: [Int] = [0, 0]
    
    init(mode: PaymentManageMode, payment: Payment?, travelCalculation: TravelCalculation) {
        self.mode = mode
        self.payment = payment
        self.travelCalculation = travelCalculation
        paymentService = PaymentService(travel: travelCalculation)
    }
    
    func addData(newData: Payment) {
        paymentService.addData(newData: newData)
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    print("Error fetching data: \(error.localizedDescription)")
                }
            } receiveValue: { _ in
                
            }
            .store(in: &cancellables)
    }
    
    func editData(editData: Payment) {
        paymentService.editData(editData: editData)
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    print("Error fetching data: \(error.localizedDescription)")
                }
            } receiveValue: { _ in
                
            }
            .store(in: &cancellables)
    }
    
    func setTitleString(userTravelStore: UserTravelStore) {
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
    
    func setTravel(travel: TravelCalculation) {
        travelCalculation = travel
        paymentDate = travel.startDate.toDate()
        isShowingSelectTripSheet = false
    }
    
    func setTravelAlertOrSheet(userTravelStore: UserTravelStore) {
        if userTravelStore.travels.isEmpty {
            isShowingNoTravelAlert = true
        }
        else {
            isShowingSelectTripSheet = true
        }
    }
    
    func setInitialValue() {
        switch(mode) {
        case .add:
            paymentDate = travelCalculation.startDate.toDate()
        case .mainAdd:
            paymentDate = travelCalculation.startDate.toDate()
        case .edit:
            if let payment = payment {
                selectedCategory = payment.type
                expandDetails = payment.content
                priceString = String(payment.payment)
                paymentDate = payment.paymentDate.toDate()
            }
        }
    }
    
    func setAddress() {
        if let p = payment {
            searchAddress = p.address.address
        }
        
        if mode == .edit {
            isShowingMapView = true
        }
    }
    
    func addPayment(settlementExpensesStore: SettlementExpensesStore, locationManager: LocationManager, notificationStore: NotificationService) {
        let newPayment =
        Payment(type: selectedCategory ?? .etc, content: expandDetails, payment: Int(priceString) ?? 0, address: Payment.Address(address: locationManager.selectedAddress, latitude: locationManager.selectedLatitude, longitude: locationManager.selectedLongitude), participants: participants, paymentDate: paymentDate.timeIntervalSince1970)
        
        addData(newData: newPayment)
//            settlementExpensesStore.setSettlementExpenses(payments: paymentStore.payments, members: travelCalculation.members)
        
        PushNotificationManager.sendPushNotification(toTravel: travelCalculation, title: "\(travelCalculation.travelTitle)여행방", body: "지출이 추가 되었습니다.", senderToken: "senderToken")
        notificationStore.sendNotification(members: travelCalculation.members, notification: UserNotification(type: .travel, content: "\(travelCalculation.travelTitle)여행방에서 확인하지 않은 지출", contentId: "\(URLSchemeBase.scheme.rawValue)://travel?travelId=\(travelCalculation.id)", addDate: Date(), isChecked: false))
    }
    
    func mainAddPayment(settlementExpensesStore: SettlementExpensesStore, locationManager: LocationManager, notificationStore: NotificationService, userTravelStore: UserTravelStore) {
        let newPayment =
        Payment(type: selectedCategory ?? .etc, content: expandDetails, payment: Int(priceString) ?? 0, address: Payment.Address(address: locationManager.selectedAddress, latitude: locationManager.selectedLatitude, longitude: locationManager.selectedLongitude), participants: participants, paymentDate: paymentDate.timeIntervalSince1970)
        userTravelStore.addPayment(travelCalculation: travelCalculation, payment: newPayment)
        
        PushNotificationManager.sendPushNotification(toTravel: travelCalculation, title: "\(travelCalculation.travelTitle)여행방", body: "지출이 추가 되었습니다.", senderToken: "senderToken")
        notificationStore.sendNotification(members: travelCalculation.members, notification: UserNotification(type: .travel, content: "\(travelCalculation.travelTitle)여행방에서 확인하지 않은 지출", contentId: "\(URLSchemeBase.scheme.rawValue)://travel?travelId=\(travelCalculation.id)", addDate: Date(), isChecked: false))
    }
    
    func editPayment(settlementExpensesStore: SettlementExpensesStore, locationManager: LocationManager, notificationStore: NotificationService) {
        if let payment = payment {
            let newPayment = Payment(id: payment.id, type: selectedCategory ?? .etc, content: expandDetails, payment: Int(priceString) ?? 0, address: Payment.Address(address: locationManager.selectedAddress, latitude: locationManager.selectedLatitude, longitude: locationManager.selectedLongitude), participants: participants, paymentDate: paymentDate.timeIntervalSince1970)
            editData(editData: newPayment)
//                settlementExpensesStore.setSettlementExpenses(payments: paymentStore.payments, members: travelCalculation.members)
            
        }
    }
    
    func pressCompleteButton() -> PaymentFocusField? {
        if mode == .mainAdd && travelCalculation.travelTitle.isEmpty {
            isShowingSelectTripSheet = true
        }
        else if selectedCategory == nil {
            return .type
        }
        else if expandDetails.isEmpty {
            return .content
        }
        else if priceString.isEmpty {
            return .price
        }
        
        isShowingAlert = true
        return nil
    }
    
    func getTextButton() -> String {
        if mode == .edit {
            return "수정하기"
        }
        return "추가하기"
    }
    
    func setMember() {
        if mode == .edit {
            if let payment = payment {
                for participant in payment.participants {
                    if let existMember = travelCalculation.members.firstIndex(where: { m in
                        m.id == participant.memberId
                    }) {
                        if let _ = members.firstIndex(of: travelCalculation.members[existMember]) {
                            continue
                        }
                        members.append(travelCalculation.members[existMember])
                    }
                }
                participants = payment.participants
                howManySeperate()
            }
        }
    }
    
    func addButton() {
        participants = []
        for member in tempMembers {
            participants.append(Payment.Participant(memberId: member.id, advanceAmount: 0, seperateAmount: 0, memo: ""))
        }
        members = tempMembers
        isShowingMemberSheet = false
    }
    
    func editButton() {
        isShowingMemberSheet = false
        
        var tempParticipants: [Payment.Participant] = []
        for m in tempMembers {
            if let participant = participants.first(where: { p in
                p.memberId == m.id
            }) {
                tempParticipants.append(participant)
            }
            else {
                tempParticipants.append(Payment.Participant(memberId: m.id, advanceAmount: 0, seperateAmount: 0, memo: ""))
            }
        }
        
        participants = tempParticipants
        payment?.participants = participants
        members = tempMembers
    }
    
    func personalPrice() {
        if let idx = participants.firstIndex(where: { p in
            p.memberId == selectedMember.id
        }) {
            participants[idx].advanceAmount = Int(advanceAmountString) ?? 0
            participants[idx].seperateAmount = Int(seperateAmountString) ?? 0
        }
        howManySeperate()
        isShowingPersonalMemberSheet = false
    }
    
    func getPersonalPrice(idx: Int) -> Int {
        if participants[idx].seperateAmount != 0 {
            return participants[idx].seperateAmount - participants[idx].advanceAmount
        }
        else {
            let numOfDutch = participants.count - seperate[0]
            var amountOfDutch = 0
            
            if mode == .edit {
                if let p = payment {
                    amountOfDutch = p.payment - seperate[1]
                }
            }
            else {
                if priceString != "" {
                    amountOfDutch = Int(priceString)! - seperate[1]
                }
                else {
                    amountOfDutch = 0 - seperate[1]
                }
                
            }
            
            return amountOfDutch / numOfDutch - participants[idx].advanceAmount
        }
    }
    
    func howManySeperate() {
        var result = 0
        var amount = 0
        
        for participant in self.participants {
            if participant.seperateAmount != 0 {
                result += 1
                amount += participant.seperateAmount
            }
        }
        
        seperate[0] = result
        seperate[1] = amount
    }
    
    func getPersonalPrice() {
        if let idx = participants.firstIndex(where: { p in
            p.memberId == selectedMember.id
        }) {
            advanceAmountString = String(participants[idx].advanceAmount)
            seperateAmountString = String(participants[idx].seperateAmount)
            personalMemo = participants[idx].memo
        }
    }
    
    func addOrDeleteMember(member: TravelCalculation.Member) {
        if let existMember = tempMembers.firstIndex(where: { m in
            m.name == member.name
        }) {
            tempMembers.remove(at: existMember)
        }
        else {
            tempMembers.append(member)
        }
    }
}
