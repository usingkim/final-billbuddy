//
//  UserTravel.swift
//  BillBuddy
//
//  Created by 윤지호 on 2023/09/25.
//  2023/09/27. 13:40

import Foundation
import FirebaseFirestoreSwift

// MyTravel로 renaming하기

struct UserTravel: Identifiable, Codable {
    @DocumentID var id: String?
    var travelId: String
}
