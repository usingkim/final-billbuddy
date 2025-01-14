//
//  TabView.swift
//  BillBuddy
//
//  Created by 윤지호 on 10/4/23.
//

import SwiftUI
import UIKit

struct BillBuddyTabView: View {
    @State private var selectedTab = 0
    @State private var isShowingAdScreen: Bool = false

    @StateObject private var floatingButtonMenuStore = FloatingButtonMenuStore()
    @EnvironmentObject private var userService: UserService
    @EnvironmentObject private var tabViewStore: TabViewModel
    
    init() {
        UITabBarItem.appearance().setTitleTextAttributes([.font:UIFont(name: "Pretendard-Bold", size: 10)!], for: .normal)
    }
    
    var body: some View {
        TabView(selection: $tabViewStore.selectedTab) {
            NavigationStack {
                TravelListView(floatingButtonMenuStore: floatingButtonMenuStore)
            }
            .toolbarBackground(
                floatingButtonMenuStore.isDimmedBackground ?
                Color.systemBlack.opacity(floatingButtonMenuStore.isDimmedBackground ? 0.6 : 0) : Color.white
                , for: .tabBar)
            
            .tabItem {
                Image(.hometap)
                    .renderingMode(.template)
                Text("홈")
            }
            .tag(0)
            
            NavigationStack {
                ChattingView()
            }
            
            .tabItem {
                Image(.chattap)
                    .renderingMode(.template)
                
                Text("채팅")
            }
            .tag(1)
            
            NavigationStack {
                MyPageView()
            }
            .tabItem {
                Image(.mypagetap)
                    .renderingMode(.template)
                
                Text("마이페이지")
            }
            .tag(2)
        }
        .accentColor(.systemBlack)
        
    }
}

#Preview {
    BillBuddyTabView()
}
