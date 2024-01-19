//
//  SampleMemeberStroe.swift
//  BillBuddy
//
//  Created by 윤지호 on 10/3/23.
//

import Foundation
import FirebaseFirestore

class JoinMemberStore: ObservableObject {    
    @Published var members: [Travel.Member] = []
    @Published var searchResult: [User] = []
    var connectedMemebers: [Travel.Member] {
        return members.filter { $0.userId != nil && $0.isExcluded == false  }
    }
    var dummyMemebers: [Travel.Member] {
        return members.filter { $0.userId == nil && $0.isExcluded == false }
    }
    var excludedMemebers: [Travel.Member] {
        return members.filter { $0.isExcluded == true }
    }
    var seletedMember: Travel.Member {
        return members[selectedmemberIndex]
    }
    
    @Published var isShowingAlert: Bool = false
    @Published var alertDescription: String = ""
    
    @Published var isSelectedMember: Bool = false
    @Published var selectedmemberIndex: Int = 0
    @Published var InitializedStore: Bool = false
    
    @Published var isSearching: Bool = false
    @Published var isfinishsearched: Bool = true
    
    var travel: Travel = Travel(hostId: "", travelTitle: "", managerId: "", startDate: 0, endDate: 0, updateContentDate: 0, members: [])
    
    @MainActor
    func initStore(travel: Travel) {
        self.travel = travel
        self.members = travel.members
        self.InitializedStore = true
    }
    
    @MainActor
    func selectMember(_ id: String) {
        guard let index = members.firstIndex(where: { $0.id == id }) else { return }
        selectedmemberIndex = index
    }
    
    @MainActor
    func saveMemeber(saveListAction: @escaping () -> Void) async {
        Task {
            do {
                self.travel.members = members
                try await FirestoreService.shared.saveDocument(collection: .travel, documentId: self.travel.id, data: self.travel)
                saveListAction()
            } catch {
                self.alertDescription = "저장을 실패하였습니다."
                self.isShowingAlert = true
            }
        }
    }
    
    @MainActor
    func addMember() {
        let newMemeber = Travel.Member(name: "인원\(members.count + 1)", advancePayment: 0, payment: 0)
        members.append(newMemeber)
        isSelectedMember = true
        print(isSelectedMember)
    }
    
    @MainActor
    func removeMember(memberId: String) {
        guard let index = members.firstIndex(where: { $0.id == memberId }) else { return }
        guard members[index].userId != nil else { return }
        members.remove(at: index)
        isSelectedMember = true
    }
    
    @MainActor
    func inviteMemberAndSave(saveListAction: @escaping () -> Void) async {
        members[selectedmemberIndex].isInvited = true
        await saveMemeber() { 
            saveListAction()
        }
        isSelectedMember = false
    }
    
    @MainActor
    func cancelInvite(_ memberId: String, saveListAction: @escaping () -> Void) {
        Task {
            guard let index = members.firstIndex(where: { $0.id == memberId }) else { return }
            members[index].isInvited = false
            await saveMemeber() { 
                saveListAction()
            }
        }
    }
    
    func getURL(memberId: String) -> URL {
        let urlString = "\(URLSchemeBase.scheme.rawValue)://travel?travelId=\(travel.id)&memberId=\(memberId)"
        guard let encodeString = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else { return URL(string: "실패!")! }
        guard let url = URL(string: encodeString) else { return URL(string: "실패!")! }
        
        return url
    }
    
    @MainActor
    func searchUser(query: String) {
        Task {
            self.isSearching = true
            do {
                var searchResult: [User] = []
                let nameSnapshot = try await Firestore.firestore().collection(StoreCollection.user.path)
                    .whereField("name", isEqualTo: query).getDocuments()
                let emailSnapshot = try await Firestore.firestore().collection(StoreCollection.user.path)
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
                self.searchResult = searchResult.filter { $0.id != AuthService.shared.userUid }
                self.isSearching = false
                self.isfinishsearched = false
            } catch {
                print("false search")
            }
        }
    }
}
