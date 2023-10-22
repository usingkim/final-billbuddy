//
//  SampleMemeberStroe.swift
//  BillBuddy
//
//  Created by 윤지호 on 10/3/23.
//

import Foundation
import FirebaseFirestore

class SampleMemeberStore: ObservableObject {    
    @Published var members: [TravelCalculation.Member] = []
    @Published var searchResult: [User] = []
    var connectedMemebers: [TravelCalculation.Member] {
        return members.filter { $0.userId != nil && $0.isExcluded == false  }
    }
    var dummyMemebers: [TravelCalculation.Member] {
        return members.filter { $0.userId == nil && $0.isExcluded == false }
    }
    var excludedMemebers: [TravelCalculation.Member] {
        return members.filter { $0.isExcluded == true }
    }
    var seletedMember: TravelCalculation.Member {
        return members[selectedmemberIndex]
    }
    
    @Published var isShowingAlert: Bool = false
    @Published var alertDescription: String = ""
    
    @Published var isSelectedMember: Bool = false
    @Published var selectedmemberIndex: Int = 0
    @Published var InitializedStore: Bool = false
    
    var travel: TravelCalculation = TravelCalculation(hostId: "", travelTitle: "", managerId: "", startDate: 0, endDate: 0, updateContentDate: 0, members: [])
    
    func initStore(travel: TravelCalculation) {
        self.travel = travel
        self.members = travel.members
        self.InitializedStore = true
    }
    
    func selectMember(_ id: String) {
        guard let index = members.firstIndex(where: { $0.id == id }) else { return }
        selectedmemberIndex = index
    }
    
    func saveMemeber() async {
        Task {
            do {
                self.travel.updateContentDate = Date.now.timeIntervalSince1970
                try await FirestoreService.shared.saveDocument(collection: .travel, documentId: self.travel.id, data: self.travel)
                
            } catch {
                self.alertDescription = "저장을 실패하였습니다."
                self.isShowingAlert = true
            }
        }
    }
    
    func addMember() {
        let newMemeber = TravelCalculation.Member(name: "인원\(members.count + 1)", advancePayment: 0, payment: 0)
        members.append(newMemeber)
        isSelectedMember = true
        print(isSelectedMember)
    }
    
    func removeMember(memberId: String) {
        guard let index = members.firstIndex(where: { $0.id == memberId }) else { return }
        guard members[index].userId != nil else { return }
        members.remove(at: index)
        isSelectedMember = true
    }
    
    func inviteMemberAndSave() async {
        members[selectedmemberIndex].isInvited = true
        await saveMemeber()
        isSelectedMember = false
    }
    
    func getURL(memberId: String) -> URL {
        let urlString = "\(URLSchemeBase.scheme.rawValue)://travel?travelId=\(travel.id)&memberId=\(memberId)"
        guard let encodeString = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else { return URL(string: "실패!")! }
        guard let url = URL(string: encodeString) else { return URL(string: "실패!")! }
        
        return url
    }
    
    func searchUser(query: String) {
        Task {
            do {
                var searchResult: [User] = []
                let nameSnapshot = try await Firestore.firestore().collection("User")
                    .whereField("name", isEqualTo: query).getDocuments()
                let emailSnapshot = try await Firestore.firestore().collection("User")
                    .whereField("email", isEqualTo: query).getDocuments()
                if nameSnapshot.isEmpty == false {
                    for document in nameSnapshot.documents {
                        let user = try document.data(as: User.self)
                        searchResult.append(user)
                    }
                }
                if emailSnapshot.isEmpty == false {
                    for document in emailSnapshot.documents {
                        let user = try document.data(as: User.self)
                        searchResult.append(user)
                    }
                }
                self.searchResult = searchResult.filter { $0.id != AuthStore.shared.userUid }
            } catch {
                print("false search")
            }
        }
    }
}
