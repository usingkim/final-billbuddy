//
//  URLSchemeBase.swift
//  BillBuddy
//
//  Created by 김유진 on 1/13/24.
//

import Foundation
/// 규칙
/// billbuddybuddy://invite?travelId=\(travelid),memberId=\(memberid)
enum URLSchemeBase: String {
    case scheme = "billbuddybuddy"
    case path = "path"
    case query = "query"
}
