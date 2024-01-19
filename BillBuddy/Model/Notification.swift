//
//  Notification.swift
//  BillBuddy
//
//  Created by 윤지호 on 10/20/23.
//

import Foundation
import FirebaseFirestoreSwift

struct Notification: Identifiable, Codable {
    @DocumentID var id: String?
    var duplicationIds: [String]?
    var type: NotiType

    var content: String
    var contentId: String
    var addDate: Date
    var isChecked: Bool = false
}

