//
//  SampleMemeberStroe.swift
//  BillBuddy
//
//  Created by 윤지호 on 10/3/23.
//

import Foundation

class SampleMemeberStore: ObservableObject {    
    @Published var members: [TravelCalculation.Member]
    @Published var isShowingAlert: Bool = false
    @Published var alertDescription: String = ""
    
    @Published var isSelectedMember: Bool = false
    @Published var selectedmemberIndex: Int = 0
    
    
    var travel: TravelCalculation
    
    init(travel: TravelCalculation) {
        self.travel = travel
        self.members = travel.members
    }
    func selectMember(_ index: Int) {
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
    
    func getURL() -> URL {
        let urlString = "\(URLSchemeBase.scheme.rawValue).//travel?id=\(travel.id)/userId=\(members[selectedmemberIndex].id)"
        guard let encodeString = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else { return URL(string: "실패!")! }
        guard let url = URL(string: encodeString) else { return URL(string: "실패!")! }
        
        return url
    }
    
    
}
