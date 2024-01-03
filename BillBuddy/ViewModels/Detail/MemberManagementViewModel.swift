//
//  MemberManagementViewModel.swift
//  BillBuddy
//
//  Created by 김유진 on 1/4/24.
//

import Foundation
import Firebase
import FirebaseFirestore

final class MemberManagementViewModel: ObservableObject {
    var travel: TravelCalculation
    var entryViewType: EntryViewType
    
    @Published var payments: [Payment]
    
    @Published var isShowingAlert: Bool = false
    @Published var isShowingSaveAlert: Bool = false
    @Published var isShowingEditSheet: Bool = false
    @Published var isShowingShareSheet: Bool = false
    @Published var isPresentedSettledAlert: Bool = false
    @Published var nickName: String = ""
    @Published var advancePayment: String = ""
    @Published var member: TravelCalculation.Member = TravelCalculation.Member(name: "", advancePayment: 0, payment: 0)
    @Published var isExcluded: Bool = false
    @Published var searchText: String = ""
    @Published var isShowingInviteAlert: Bool = false
    @Published var seletedUser: User = User(email: "", name: "", bankName: "", bankAccountNum: "", isPremium: false, premiumDueDate: Date.now, reciverToken: "")
    @Published var isfinishsearched: Bool = true
    
    var saveAction: () -> Void = {}
    
    init(travel: TravelCalculation, entryViewType: EntryViewType) {
        self.travel = travel
        self.entryViewType = entryViewType
        self.payments = []
        
        if entryViewType == .list {
            fetchPayments()
        }
    }
    
    func saveChange(joinMemberStore: JoinMemberStore, userTravelStore: UserTravelStore) async {
        await joinMemberStore.saveMemeber() {
            if self.entryViewType == .list {
                userTravelStore.setTravelMember(travelId: self.travel.id, members: joinMemberStore.members)
            }
        }
        if entryViewType == .list {
            fetchPayments()
        }
    }
    
    func setMemberAndIsExcluded(m: TravelCalculation.Member) {
        member = m
        isExcluded = m.isExcluded
    }
    
    func setMemeber() {
        let nickName = nickName.isEmpty ? member.name : nickName
        member.name = nickName
        member.advancePayment = Int(advancePayment) ?? 0
        member.isExcluded = isExcluded
        isShowingEditSheet = false
    }
    
    func fetchPayments() {
        Task {
            do {
                let snapshot = try await Firestore.firestore()
                    .collection(StoreCollection.travel.path).document(travel.id)
                    .collection(StoreCollection.payment.path).getDocuments()
                
                let result = try snapshot.documents.map { try $0.data(as: Payment.self) }
                payments = result
                
            } catch {
                print("false fetch payments - \(error)")
            }
        }
    }
    
    func inviteMember(joinMemberStore: JoinMemberStore, notificationStore: NotificationStore) {
        Task {
            let noti = UserNotification(
                type: .invite,
                content: "\(joinMemberStore.travel.travelTitle) 에서 당신을 초대했습니다",
                contentId: "\(URLSchemeBase.scheme.rawValue)://travel?travelId=\(joinMemberStore.travel.id )&memberId=\(joinMemberStore.seletedMember.id)",
                addDate: Date.now)
            await joinMemberStore.inviteMemberAndSave() {
                self.saveAction()
            }
            notificationStore.sendNotification(users: [seletedUser], notification: noti)
            
            if let serverKey = ServerKeyManager.loadServerKey() {
                PushNotificationManager.sendPushNotificationToToken(seletedUser.reciverToken, title: "여행 초대", body: "\(joinMemberStore.travel.travelTitle)에서 당신을 초대했습니다", senderToken: UserService.shared.currentUser?.reciverToken ?? "", serverKey: serverKey)
            }
            
            isShowingShareSheet = false
        }
    }
    
    @MainActor
    func dismissAction(settlementExpensesStore: SettlementExpensesStore, travelDetailStore: TravelDetailStore, joinMemberStore: JoinMemberStore) {
        // TODO: payments가 안들어오나? 암튼 ... 나중에 해보쟈
        settlementExpensesStore.setSettlementExpenses(payments: payments, members: joinMemberStore.members)
        travelDetailStore.stoplistening()
    }
}
