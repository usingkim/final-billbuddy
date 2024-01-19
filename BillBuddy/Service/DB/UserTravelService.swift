//
//  UserTravelService.swift
//  BillBuddy
//
//  Created by 김유진 on 1/18/24.
//

import Foundation
import Combine
import FirebaseFirestore

final class UserTravelService: ObservableObject, FirebaseProtocol {
    typealias DBData = MyTravel
    
    var dbRef: CollectionReference = Firestore.firestore().collection(StoreCollection.user.path)
        .document(AuthService.shared.userUid).collection(StoreCollection.userTravel.path)
    
    func fetchAll() -> AnyPublisher<[MyTravel], Error> {
        return Future { promise in
            self.dbRef.getDocuments { querySnapshot, error in
                if let error = error {
                    promise(.failure(error))
                } else {
                    do {
                        let documents = try querySnapshot?.documents
                            .map { try $0.data(as: MyTravel.self) }
                        promise(.success(documents ?? []))
                    } catch {
                        promise(.failure(error))
                    }
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    func addData(newData: MyTravel) -> AnyPublisher<MyTravel, Error> {
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
    
    func editData(editData: MyTravel) -> AnyPublisher<MyTravel, Error> {
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
    
    func deleteData(deleteData: MyTravel) -> AnyPublisher<Void, Error> {
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
