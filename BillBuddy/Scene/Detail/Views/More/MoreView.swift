//
//  MoreView.swift
//  BillBuddy
//
//  Created by 김유진 on 10/4/23.
//

import SwiftUI

enum ListItem: String, CaseIterable {
    case chat
//    case editDate
    case mamberManagement
    case settledAccount
    
    var itemName: String {
        switch self {
        case .chat:
            "채팅"
//        case .editDate:
//            "날짜 수정"
        case .mamberManagement:
            "인원관리"
        case .settledAccount:
            "결산"
        }
    }
    
    var itemImageString: String {
        switch self {
        case .chat:
            "chat-bubble-text-square1"
//        case .editDate:
//            "calendar-check-1"
        case .mamberManagement:
            "user-single-neutral-male-4"
        case .settledAccount:
            "script-2-18"
        }
    }
}

struct MoreView: View {
    @Environment(\.dismiss) private var dismiss

    var travel: TravelCalculation
    @State var itemList: [ListItem] = ListItem.allCases
    
    var body: some View {
        Divider()
            .padding(.bottom, 16)
        ScrollView {
            VStack {
                ForEach(ListItem.allCases, id: \.self) { item in
                    NavigationLink {
                        switch item {
                        case .chat:
                            ChattingRoomView(travel: travel)
//                        case .editDate:
//                            SpendingListView()
                        case .mamberManagement:
                            MemberManagementView(travel: travel)
                        case .settledAccount:
                            SpendingListView()
                        }
                    } label: {
                        MoreListCell(item: item)
                    }
                    .listRowSeparator(.hidden, edges: /*@START_MENU_TOKEN@*/.all/*@END_MENU_TOKEN@*/)
                }
                
                Spacer()
            }
        }
        .navigationBarBackButtonHidden()
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button(action: {
                    dismiss()
                }, label: {
                    Image("arrow_back")
                        .resizable()
                        .frame(width: 24, height: 24)
                })
                
            }
            ToolbarItem(placement: .principal) {
                Text("더보기")
                    .font(.title05)
                    .foregroundColor(Color.systemBlack)
            }
        }
    }
}

#Preview {
    NavigationStack {
        MoreView(travel: .sampletravel)
    }
}
