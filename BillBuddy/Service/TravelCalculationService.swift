//
//  TravelCalculationService.swift
//  BillBuddy
//
//  Created by 김유진 on 1/18/24.
//
import Foundation
import Combine
import FirebaseFirestore

final class TravelCalculationService: ObservableObject, FirebaseProtocol {
    typealias DBData = TravelCalculation
    var dbRef: CollectionReference = Firestore.firestore().collection(StoreCollection.travel.path)
    
    var userTravels: [UserTravel]
    
    init(userTravels: [UserTravel]) {
        self.userTravels = userTravels
    }
    
    func fetchAll() -> AnyPublisher<[TravelCalculation], Error> {
        // userTravel의 id 이용해서 [TravelCalculation]으로 fetch 해야한다.
    }
    
    func addData(newData: TravelCalculation) -> AnyPublisher<TravelCalculation, Error> {
        <#code#>
    }
    
    func editData(editData: TravelCalculation) -> AnyPublisher<TravelCalculation, Error> {
        <#code#>
    }
    
    func deleteData(deleteData: TravelCalculation) -> AnyPublisher<Void, Error> {
        <#code#>
    }
    
}
