//
//  TravelDetailStroe.swift
//  BillBuddy
//
//  Created by 윤지호 on 10/17/23.
//

import SwiftUI
import Firebase
import FirebaseFirestoreSwift

// Firebase 결합 -> 다른데서 하도록 해야된당

final class TravelDetailStore: ObservableObject {
    @Published var travel: TravelCalculation
    @Published var isChangedTravel: Bool = false
    @Published var isFirstFetch: Bool = true
    
    var travelTmp: TravelCalculation
    var travelId: String
    let dbRef = Firestore.firestore().collection(StoreCollection.travel.path) // "TravelCalculation"
    var listener: ListenerRegistration? = nil
    
    init() {
        travelTmp = TravelCalculation(hostId: "", travelTitle: "", managerId: "", startDate: 0, endDate: 0, updateContentDate: 0, members: [])
        travelId = ""
        self.travel = travelTmp
    }
    
    init(travel: TravelCalculation) {
        self.travel = travel
        self.travelTmp = travel
        self.travelId = travel.id
    }
    
    @MainActor
    func setTravel(travel: TravelCalculation) {
        self.travelTmp = travel
        self.travel = travel
        self.travelId = travel.id
    }
    
    @MainActor
    func setTravelDates(_ startDate: Date, _ endDate: Date) {
        if travel.isPaymentSettled { return }
        self.travel.startDate = startDate.timeIntervalSince1970
        self.travel.endDate = endDate.timeIntervalSince1970
    }
    
    func fetchTravel() {
        if travel.isPaymentSettled { return }
        Task {
            do {
                let snapshot = try await dbRef.document(travelId).getDocument()
                let travel = try snapshot.data(as: TravelCalculation.self)
                DispatchQueue.main.async {
                    self.travel = travel
                }
            } catch {
                print("false fetch travel - \(error)")
            }
        }
    }
    
    func checkAndResaveToken() {
        guard let index = travelTmp.members.firstIndex(where: { $0.userId == AuthStore.shared.userUid }) else { return }
        if travelTmp.members[index].reciverToken != UserService.shared.reciverToken {
            travelTmp.members[index].reciverToken = UserService.shared.reciverToken
            travelTmp.updateContentDate = Date.now.timeIntervalSince1970
            do {
                try Firestore.firestore().collection(StoreCollection.travel.path).document(self.travelId).setData(from: travel.self)
            } catch {
                print("resave token false")
            }
        }
    }
    
    // 해당 여행에 updateDate 최신화
    func saveUpdateDate() {
        if travel.isPaymentSettled { return }
        Task {
            try await Firestore.firestore().collection(StoreCollection.travel.path).document(self.travelId).setData(["updateContentDate":Date.now.timeIntervalSince1970], merge: true)
        }
    }
    
    /// DetailView 리스닝
    func listenTravelDate() {
        if travel.isPaymentSettled { return }
        self.listener = dbRef.document(travelId).addSnapshotListener { querySnapshot, error in
            if let error = error {
                print("Error retreiving collection: \(error)")
            }
            print("listenTravelDate1")
            do {
                guard let snapshot = querySnapshot else { return }
                let travel = try snapshot.data(as: TravelCalculation.self)
                // 여행 변경사항이 있을 시
                DispatchQueue.main.async {
                    if self.isFirstFetch {
                        self.travel = travel
                        return
                    }
                    // 맴버가 바뀌었을시엔 바로 바꿔줌
                    if travel.members != self.travel.members {
                        self.travel = travel
                    }
                    // updateContentDate가 변경됐을 시엔
                    if travel.updateContentDate > self.travel.updateContentDate {
                        self.travel = travel
                        self.isChangedTravel = true
                    } else {
                        self.isChangedTravel = false
                    }
                    
                }
            } catch {
                print("travel Detail - decoding false")
            }
        }
    }
    
    func setIsPaymentSettled(isSettle: Bool) {
        dbRef.document(travelId).setData(
            [
                "isPaymentSettled": isSettle
            ], merge: true)
        DispatchQueue.main.async {
            self.travel.isPaymentSettled = isSettle
        }
    }

    
    /// 인원관리뷰 리스닝
    func listenTravelDate(callback: @escaping (TravelCalculation) -> Void) {
        if travel.isPaymentSettled { return }
        self.listener = dbRef.document(travelId).addSnapshotListener { querySnapshot, error in
            if let error = error {
                print("Error retreiving collection: \(error)")
            }
            print("listenTravelDate2")
            do {
                guard let snapshot = querySnapshot else { return }
                let travel = try snapshot.data(as: TravelCalculation.self)
                // 여행 변경사항이 있을 시
                DispatchQueue.main.async {
                    if self.isFirstFetch {
                        self.travel = travel
                    }
                    // 맴버가 바뀌었을시엔 바로 바꿔줌
                    if travel.members != self.travel.members {
                        self.travel = travel
                        callback(travel)
                    }
                    // updateContentDate가 변경됐을 시엔
                    if travel.updateContentDate > self.travel.updateContentDate {
                        self.travel = travel
                        callback(travel)
                        self.isChangedTravel = true
                    } else {
                        self.isChangedTravel = false
                    }
                    
                }
            } catch {
                print("travel Detail - decoding false")
            }
        }
    }
    
    func stoplistening() {
        listener?.remove()
        print("stop listening")
        isChangedTravel = false
    }
}
