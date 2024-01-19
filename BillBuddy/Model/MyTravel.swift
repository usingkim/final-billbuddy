//
//  UserTravel.swift
//  BillBuddy
//
//  Created by 윤지호 on 2023/09/25.
//  2023/09/27. 13:40

import Foundation
import FirebaseFirestoreSwift

struct MyTravel: Identifiable, Codable {
    @DocumentID var id: String?
    var travelId: String
}
