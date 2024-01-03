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
    
    init(travel: TravelCalculation, entryViewType: EntryViewType) {
        self.travel = travel
        self.entryViewType = entryViewType
        self.payments = []
        
        if entryViewType == .list {
            fetchPayments()
        }
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
}
