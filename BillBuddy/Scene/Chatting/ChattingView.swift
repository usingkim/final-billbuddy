//
//  ChattingView.swift
//  BillBuddy
//
//  Created by 윤지호 on 2023/09/22.
//

import SwiftUI

struct ChattingView: View {
    @EnvironmentObject private var travelStore: UserTravelStore
    @EnvironmentObject private var notificationStore: NotificationService
    @EnvironmentObject private var tabBarVisibilityStore: TabBarVisibilityStore
    @EnvironmentObject private var tabViewStore: TabViewModel
    
    var body: some View {
        VStack {
            if sortedList().isEmpty {
                emptyList
            } else {
                ScrollView {
                    chattingItems
                        .padding(.top, 5)
                }
            }
            Divider().padding(0)
        }
        .navigationDestination(isPresented: $tabViewStore.isPresentedChat) {
            if let travel = tabViewStore.seletedTravel {
                ChattingRoomView(travel: travel)
            }
        }
        .onAppear {
            tabBarVisibilityStore.showTabBar()
            if !AuthService.shared.userUid.isEmpty {
                travelStore.fetchTravelCalculation()
            }
        }
        .toolbar(tabBarVisibilityStore.visibility, for: .tabBar)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Text("채팅")
                    .font(.title05)
                    .foregroundColor(.systemBlack)
            }
            ToolbarItem(placement: .topBarTrailing) {
                NavigationLink {
                    NotificationListView()
                } label: {
                    if notificationStore.hasUnReadNoti {
                        Image(.redDotRingBell)
                            .resizable()
                            .frame(width: 24, height: 24)
                    }
                    else {
                        Image("ringing-bell-notification-3")
                            .resizable()
                            .frame(width: 24, height: 24)
                    }
                }
            }
        }
    }
    
    private var emptyList: some View {
        VStack {
            Spacer()
            Text("참여 중인 채팅이 없습니다.")
                .font(.body04)
                .foregroundColor(.gray600)
            Spacer()
        }
    }
    
    private var chattingItems: some View {
        ForEach(sortedList()) { travel in
            Button {
                tabViewStore.pushView(type: .chatting, travel: travel)
            } label: {
                HStack {
                    Image(.chatroom)
                        .resizable()
                        .frame(width: 48, height: 48)
                    VStack(alignment: .leading) {
                        HStack {
                            Text(travel.travelTitle)
                                .font(Font.body02)
                                .foregroundColor(.systemBlack)
                            
                            Text("\(travel.members.count)")
                                .font(Font.body02)
                                .foregroundColor(.gray500)
                        }
                        if let messagePreview = travel.lastMessage {
                            Text(messagePreview)
                                .font(Font.body04)
                                .foregroundColor(.gray700)
                                .lineLimit(/*@START_MENU_TOKEN@*/2/*@END_MENU_TOKEN@*/)
                                .multilineTextAlignment(.leading)
                        }
                    }
                    Spacer()
                    VStack(alignment: .trailing) {
                        if let lastMessageTime = travel.lastMessageDate?.toFormattedChatDate() {
                            Text("\(lastMessageTime)")
                                .font(Font.caption01)
                                .foregroundColor(.gray500)
                        }
                        if let unreadMessage = travel.unreadMessageCount?[AuthService.shared.userUid], unreadMessage > 0 {
                            Text("\(unreadMessage)")
                                .frame(width: 16, height: 16)
                                .font(Font.caption03)
                                .foregroundColor(.white)
                                .background(Color.error)
                                .cornerRadius(50)
                        }
                    }
                }
            }
            .padding(.horizontal)
            .frame(maxWidth: .infinity)
            .frame(height: 80)
        }
        .padding(2)
    }
    
    private func sortedList() -> [Travel] {
        let sortedItems = travelStore.travels.sorted { (firstTravel, secondTravel) in
                if let firstDate = firstTravel.lastMessageDate, let secondDate = secondTravel.lastMessageDate {
                    // 1. lastMessageDate 최신순
                    return firstDate > secondDate
                } else if firstTravel.lastMessageDate != nil {
                    // firstTravel은 lastMessageDate가 있고, secondTravel은 없는 경우
                    return true
                } else if secondTravel.lastMessageDate != nil {
                    // secondTravel은 lastMessageDate가 있고, firstTravel은 없는 경우
                    return false
                } else {
                    // 2. startDate 빠른순
                    return firstTravel.startDate < secondTravel.startDate
                }
            }
        return sortedItems
    }

}

#Preview {
    NavigationStack {
        ChattingView()
            .environmentObject(UserTravelStore())
            .environmentObject(TabBarVisibilityStore())
            .environmentObject(NotificationService.shared)
    }
}

