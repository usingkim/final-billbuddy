//
//  Payment.swift
//  BillBuddy
//
//  Created by 윤지호 on 2023/09/22.
//  2023/09/27. 13:40

import Foundation
import FirebaseFirestoreSwift
/// 결제 - 추가, 또는 수정 시 리얼타임 베이스에 갱신일 최신화
struct Payment: Identifiable, Codable {
    @DocumentID var id: String?
    
    var type: PaymentType
    var content: String
    var payment: Int
    let address: Address
    var participants: [Participant]
    var paymentDate: Double
    
    struct Address: Codable {
        let address: String
        /// 위도
        let latitude: Double
        /// 경도
        let longitude: Double
    }
    
    struct Participant: Codable, Hashable {
        var memberId: String
        /// 먼저 지불한 금액
        var advanceAmount: Int
        /// 개인 사용 금액
        var seperateAmount: Int
        var memo: String
    }
    
    enum PaymentType: CaseIterable, Codable {
        case transportation
        case accommodation
        case tourism
        case food
        case etc
        
        var string: String {
            switch self {
            case .transportation:
                return "교통"
            case .accommodation:
                return "숙박"
            case .tourism:
                return "관광"
            case .food:
                return "식비"
            case .etc:
                return "기타"
            }
        }
        
        enum ImageType: String {
            case nomal = ""
            case thin = "-thin"
            case badge = "-badge"
        }
        
        func getImageString(type: ImageType) -> String {
            switch self {
            case .accommodation:
                return "hotel-bed-5-2\(type.rawValue)"
            case .food:
                return "fork-knife-9\(type.rawValue)"
            case .transportation:
                return "bus-39\(type.rawValue)"
            case .tourism:
                return "beach-36\(type.rawValue)"
            case .etc:
                return "etc\(type.rawValue)"
            }
        }
        
        static func fromRawString(_ rawString: String) -> PaymentType {
               switch rawString {
               case "교통":
                   return .transportation
               case "숙박":
                   return .accommodation
               case "관광":
                   return .tourism
               case "식비":
                   return .food
               default:
                   return .etc
               }
           }
    }
}
