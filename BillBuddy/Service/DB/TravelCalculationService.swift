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
    
    func fetchTravel(travel: UserTravel) -> AnyPublisher<TravelCalculation, Error> {
        return Future { promise in
            self.dbRef.document(travel.travelId).getDocument { doc, error in
                if let error = error {
                    promise(.failure(error))
                } else {
                    do {
                        let travel = try doc?.data(as: TravelCalculation.self)
                        promise(.success(travel!))
                    } catch {
                        promise(.failure(error))
                    }
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    func fetchAll() -> AnyPublisher<[TravelCalculation], Error> {
        return Future { promise in
            let travels: [TravelCalculation] = []
            
            promise(.success(travels))
        }
        .eraseToAnyPublisher()
    }
    
    func addData(newData: TravelCalculation) -> AnyPublisher<TravelCalculation, Error> {
        return Future { promise in
            do {
                try self.dbRef.document(newData.id).setData(from: newData) { error in
                    if let error = error {
                        promise(.failure(error))
                    } else {
                        promise(.success(newData))
                    }
                }
            } catch {
                promise(.failure(error))
            }
        }
        .eraseToAnyPublisher()
    }
    
    func editData(editData: TravelCalculation) -> AnyPublisher<TravelCalculation, Error> {
        return Future { promise in
            do {
                try self.dbRef.document(editData.id).setData(from: editData) { error in
                    if let error = error {
                        promise(.failure(error))
                    } else {
                        promise(.success(editData))
                    }
                }
            } catch {
                promise(.failure(error))
            }
        }
        .eraseToAnyPublisher()
    }
    
    func deleteData(deleteData: TravelCalculation) -> AnyPublisher<Void, Error> {
        return Future { promise in
            self.dbRef.document(deleteData.id).delete { error in
                if let error = error {
                    promise(.failure(error))
                } else {
                    promise(.success(()))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
}
