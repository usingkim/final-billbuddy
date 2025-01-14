//
//  TravelCalculation.swift
//  BillBuddy
//
//  Created by 윤지호 on 2023/09/22.
//  2023/09/27. 13:40

import Foundation
import FirebaseFirestoreSwift

struct Travel: Identifiable, Codable {
    var id: String = UUID().uuidString
    
    /// 방 호스트 user id
    let hostId: String
    var travelTitle: String
    /// 총무id
    var managerId: String
    var startDate: Double
    var endDate: Double
    var updateContentDate: Double
    var isPaymentSettled: Bool = false
    var members: [Member]
    // 채팅: 마지막 메세지 내용 - 미리보기
    var lastMessage: String?
    // 채팅: 마지막 메세지 날짜 -- 미리보기, 리스트 정렬 순서
    var lastMessageDate: Double?
    // 채팅: 읽지 않은 메세지 수 [유저아이디 : 갯수]
    var unreadMessageCount: [String : Int]?
    // 채팅방 공지
    var chatNotice: [Notice]?
    // 채팅방 이미지 리스트
    var chatImages: [String]?
    
    // 채팅 공지사항 구조체
    struct Notice: Codable, Hashable {
        let notice: String
        let name: String
        let date: Double
    }
    
    struct Member: Codable, Identifiable, Hashable {
        var id: String = UUID().uuidString
        /// uid / nil이면 user가 들어와있지않은 임시 맴버
        var userId: String?
        var name: String
        /// 제외된 인원인지(Payment에서 선택 제외)
        var isExcluded: Bool = false
        /// 초대중인지
        var isInvited: Bool = false
        /// 선금
        var advancePayment: Int
        /// 쓴비용 중간중간 + - << 추가 할지 말지 고민해야함.
        var payment: Int
        // 추가
        var userImage: String = ""
        var bankName: String = ""
        var bankAccountNum: String = ""
        /// 알림 토큰
        var reciverToken: String = ""
        
        var inviteState: InviteState {
            if isInvited && userId != nil {
                return .invited
            } else if isInvited && userId == nil {
                return .wating
            } else {
                return .dummy
            }
        }
        
        enum InviteState: String {
            case invited
            case wating
            case dummy
            
            var string: String {
                switch self {
                case .invited:
                    "초대됨"
                case .wating:
                    "초대중"
                case .dummy:
                    "초대하기"
                }
            }
        }
    }
}
