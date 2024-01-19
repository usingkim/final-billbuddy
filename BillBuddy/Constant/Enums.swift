//
//  ViewTypeEnums.swift
//  BillBuddy
//
//  Created by 김유진 on 1/4/24.
//

import Foundation
/// 규칙
/// billbuddybuddy://invite?travelId=\(travelid),memberId=\(memberid)
enum URLSchemeBase: String {
    case scheme = "billbuddybuddy"
    case path = "path"
    case query = "query"
}

enum StoreCollection: String {
    case user
    case travel
    case payment
    case userTravel
    case notification
    
    var path: String {
        switch self {
        case .user:
            return "User"
        case .travel:
            return "TravelCalculation"
        case .payment:
            return "Payment"
        case .userTravel:
            return "UserTravel"
        case .notification:
            return "Notification"
        }
    }
}

enum EntryViewType {
    case list
    case more
}

enum PaymentManageMode {
    case mainAdd
    case add
    case edit
}

enum PaymentFocusField {
    case travel
    case date
    case type
    case content
    case member
    case price
}

enum NotiType: String, Codable {
    case chatting
    case travel
    case notice
    case invite
    
    var title: String {
        switch self {
        case .chatting:
            return "채팅"
        case .travel:
            return "지출"
        case .notice:
            return "공지사항"
        case .invite:
            return "초대"
        }
    }
    
    var alreadyReadImageString: String {
        switch self {
        case .chatting:
            return "chat-read-badge"
        case .travel:
            return "notification-read-badge"
        case .notice:
            return "announcement-read-badge"
        case .invite:
            return "notification-read-badge"
        }
    }
    
    var notReadImageString: String {
        switch self {
        case .chatting:
            return "chat-badge"
        case .travel:
            return "notification-badge"
        case .notice:
            return "announcement-badge"
        case .invite:
            return "notification-badge"
        }
    }
    
}

enum TravelFilter: Int, CaseIterable {
    case paymentInProgress
    case paymentSettled
    
    var title: String {
        switch self {
        case .paymentInProgress: return "정산 중 여행"
        case .paymentSettled: return "정산 완료 여행"
        }
    }
}
