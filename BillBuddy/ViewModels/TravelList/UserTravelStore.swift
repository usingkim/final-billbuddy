//
//  UserTravelStore.swift
//  BillBuddy
//
//  Created by Ari on 2023/10/03.
//

import FirebaseFirestore
import FirebaseFirestoreSwift


/// 현재 UserTravelStore에 UserTravel이랑 TravelCalculation이 함께 있다.
/// UserTravelService랑 TravelCalculationService 따로 두고 보는게 좋을듯

final class UserTravelStore: ObservableObject {
    @Published var userTravels: [MyTravel] = []
    @Published var travels: [Travel] = []
    @Published var isFetchedFirst: Bool = false
    @Published var isFetching: Bool = false
        
    private let service = Firestore.firestore()
    
    var travelCount: Int {
        travels.isEmpty ? 2 : travels.count
    }
    
    init() {
        Task { await fetchFirstInit() }
    }
    
    @MainActor
    func fetchFirstInit() {
        if AuthService.shared.userUid.isEmpty == false && isFetchedFirst == false {
            fetchTravelCalculation()
        }
    }
    
    @MainActor
    func fetchTravelCalculation() {
        let userId = AuthService.shared.userUid
        
        Task {
            self.isFetching = true
            userTravels.removeAll()
            do {
                let snapshot = try await
                self.service.collection(StoreCollection.user.path).document (userId).collection(StoreCollection.userTravel.path).getDocuments()
                var travelIds: Set<String> = []
                for document in snapshot.documents {
                    do {
                        let snapshot = try document.data(as: MyTravel.self)
                        userTravels.append(snapshot)
                        travelIds.insert(snapshot.travelId)
                    } catch {
                        print(error)
                    }
                }
                
                var newTravels: [Travel] = []
                for travelId in travelIds {
                    do {
                        let snapshotData = try await self.service.collection(StoreCollection.travel.path).document(travelId).getDocument()
                        let travel = try snapshotData.data(as: Travel.self)
                        newTravels.append(travel)
                    } catch {
                        print(error)
                    }
                }
                travels.removeAll()
                
                self.travels = newTravels
                self.isFetching = false
                self.isFetchedFirst = true
            } catch {
                print ("Failed fetch travel list: \(error)")
            }
        }
    }
    
    func getTravel(id: String) -> Travel? {
        guard let contentId = id.split(separator: "=").last else { return nil }
        guard let travelIndex = travels.firstIndex(where: { $0.id == contentId }) else { return nil }
        return travels[travelIndex]
    }
    
    func addTravel(_ title: String, memberCount: Int, startDate: Date, endDate: Date) {
        var tempMembers: [Travel.Member] = []
        if memberCount > 0 {
            for index in 1...memberCount {
                if index == 1 {
                    guard let user = UserService.shared.currentUser else { return }
                    let member = Travel.Member(userId: user.id, name: user.name, isExcluded: false, isInvited: true, advancePayment: 0, payment: 0, userImage: user.userImage ?? "",bankName: user.bankName, bankAccountNum: user.bankAccountNum, reciverToken: user.reciverToken)
                    tempMembers.append(member)
                } else {
                    let member = Travel.Member(name: "인원\(index)", advancePayment: 0, payment: 0)
                    tempMembers.append(member)
                }
            }
        }
        let userId = AuthService.shared.userUid
        
        let tempTravel = Travel(
            hostId: userId,
            travelTitle: title,
            managerId: userId,
            startDate: startDate.timeIntervalSince1970.timeTo00_00_00(),
            endDate: endDate.timeIntervalSince1970.timeTo11_59_59(),
            updateContentDate: 0,
            isPaymentSettled: false,
            members: tempMembers
        )
        
        let userTravel = MyTravel(
            travelId: tempTravel.id
        )
        
        do {
            try service.collection(StoreCollection.travel.path).document(tempTravel.id).setData(from: tempTravel)
            try service.collection(StoreCollection.user.path).document(userId).collection(StoreCollection.userTravel.path).addDocument(from: userTravel)
            Task { await fetchTravelCalculation() }
        } catch {
            print("Error adding travel: \(error)")
        }
    }
    
    func addPayment(travelCalculation: Travel, payment: Payment) {
        try! service.collection(StoreCollection.travel.path).document(travelCalculation.id).collection(StoreCollection.payment.path).addDocument(from: payment.self)
    }
    
    func findTravelCalculation(userTravel: MyTravel) -> Travel? {
        return travels.first { travel in
            userTravel.travelId == travel.id
        }
    }
    
    func setTravelDate(travelId: String, startDate: Date, endDate: Date) {
        guard let index = travels.firstIndex(where: { $0.id == travelId }) else { return }
        travels[index].startDate = startDate.timeIntervalSince1970
        travels[index].endDate = endDate.timeIntervalSince1970

    }
    
    func setTravelMember(travelId: String, members: [Travel.Member]) {
        guard let index = travels.firstIndex(where: { $0.id == travelId }) else { return }
        travels[index].members = members
    }
    
    @MainActor
    // FIXME: 떠나기 시 무조건 내용 삭제됨(남은 멤버가 있는 경우에는 유지되어야함). Payment는 유지됨
    func leaveTravel(travel: Travel) {
        let userId = AuthService.shared.userUid
        let travelId = travel.id
        guard let userTravelArrayIndex = userTravels.firstIndex(where: { $0.travelId == travelId }) else { return }
        let userTravel = userTravels[userTravelArrayIndex]
        
        var members = travel.members
        guard let memberIndex = members.firstIndex(where: { $0.userId == userId }) else { return }
        members[memberIndex].isExcluded = true
        members[memberIndex].userId = nil
        
        Task {
            do {
                try await Firestore.firestore()
                    .collection(StoreCollection.user.path).document(userId)
                    .collection(StoreCollection.userTravel.path).document(userTravel.id ?? "").delete()
                
                if members.filter({ $0.userId != nil }).isEmpty {
                    try await Firestore.firestore().collection(StoreCollection.travel.path).document(travelId).delete()
                } else {
                    var updatedTravel = travel
                    updatedTravel.members = members
                    try Firestore.firestore().collection(StoreCollection.travel.path).document(travelId)
                        .setData(from: updatedTravel.self, merge: true)
                }
                self.fetchTravelCalculation()
            } catch {
                print(error)
            }
        }
    }
    
    @MainActor
    func resetStore() {
        for travel in travels {
            leaveTravel(travel: travel)
            print("resetStore 진입")
        }
//        userTravels = []
//        travels = []
        isFetchedFirst = false
    }
}
