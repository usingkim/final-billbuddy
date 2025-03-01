//
//  FirebaseService.swift
//  BillBuddy
//
//  Created by 김유진 on 1/16/24.
//

import Foundation
import FirebaseFirestore
import Combine

protocol FirebaseProtocol {
    associatedtype DBData
    
    var dbRef: CollectionReference { get set }
    
    func fetchAll() -> AnyPublisher<[DBData], Error>
    func addData(newData: DBData) -> AnyPublisher<DBData, Error>
    func editData(editData: DBData) -> AnyPublisher<DBData, Error>
    func deleteData(deleteData: DBData) -> AnyPublisher<Void, Error>
    
}
