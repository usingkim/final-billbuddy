//
//  PaymentService.swift
//  BillBuddy
//
//  Created by 김유진 on 1/16/24.
//

import Foundation
import FirebaseFirestore
import Combine

final class PaymentService: ObservableObject, FirebaseService {
    
    var dbRef: CollectionReference
    typealias DBData = Payment
    
    var travelId: String
    
    init(travel: TravelCalculation) {
        self.dbRef = Firestore.firestore().collection("TravelCalculation")
            .document(travel.id).collection("Payment")
        self.travelId = travel.id
    }
    
    func fetchAll() -> AnyPublisher<[DBData], Error> {
        return Future { promise in
            self.dbRef.order(by: "paymentDate")
                .getDocuments { querySnapshot, error in
                    if let error = error {
                        promise(.failure(error))
                    } else {
                        do {
                            let documents = try querySnapshot?.documents
                                .map { try $0.data(as: Payment.self) }
                            promise(.success(documents ?? []))
                        } catch {
                            promise(.failure(error))
                        }
                    }
            }
        }
        .eraseToAnyPublisher()
    }
    
    func addData(newData: Payment) -> AnyPublisher<DBData, Error> {
        return Future { promise in
            do {
                try self.dbRef.addDocument(from: newData.self) { error in
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
    
    func editData(editData: Payment) -> AnyPublisher<DBData, Error> {
        return Future { promise in
            if let id = editData.id {
                do {
                    try self.dbRef.document(id).setData(from: editData) { error in
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
        }
        .eraseToAnyPublisher()
    }
    
    func updateDate() -> AnyPublisher<Double, Error> {
        return Future { promise in
                let newUpdateDate = Date.now.timeIntervalSince1970
                Firestore.firestore()
                    .collection(StoreCollection.travel.path)
                    .document(self.travelId)
                    .setData(["updateContentDate": newUpdateDate], merge: true) { error in
                    if let error = error {
                        promise(.failure(error))
                    }
                        else {
                            promise(.success(newUpdateDate))
                        }
                }
            
        }
        .eraseToAnyPublisher()
    }
    
    func deleteData(deleteData: Payment) -> AnyPublisher<Void, Error> {
        return Future { promise in
            if let id = deleteData.id {
                self.dbRef.document(id).delete { error in
                    if let error = error {
                        promise(.failure(error))
                    } else {
                        promise(.success(()))
                    }
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
}
