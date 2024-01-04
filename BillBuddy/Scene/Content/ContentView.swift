//
//  ContentView.swift
//  BillBuddy
//
//  Created by 윤지호 on 2023/09/22.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var userService: UserService = .shared
    @StateObject private var inviteTravelService: InviteTravelService = .shared
    @StateObject private var notificationStore = NotificationStore.shared
    @StateObject private var tabViewStore = TabViewStore.shared
    
    @StateObject private var userTravelStore = UserTravelStore()
    @StateObject private var settlementExpensesStore = SettlementExpensesStore()
    @StateObject private var messageStore = MessageStore()
    @StateObject private var tabBarVisivilyStore = TabBarVisibilityStore()
    @StateObject private var nativeViewModel = NativeAdViewModel()
    @StateObject private var myPageStore = MyPageStore()
    @StateObject private var adViewModel = AdViewModel()
    
    var body: some View {
        if AuthStore.shared.userUid != "" {
            if userService.isSignIn {
                if inviteTravelService.isLoading == false {
                    BillBuddyTabView()
                        .environmentObject(settlementExpensesStore)
                        .environmentObject(userTravelStore)
                        .environmentObject(messageStore)
                        .environmentObject(userService)
                        .environmentObject(tabBarVisivilyStore)
                        .environmentObject(notificationStore)
                        .environmentObject(inviteTravelService)
                        .environmentObject(nativeViewModel)
                        .environmentObject(myPageStore)
                        .environmentObject(adViewModel)
                        .environmentObject(tabViewStore)
                        .onAppear {
                            notificationStore.fetchNotification()
                        }
                } else {
                    NavigationStack {
                        LodingView()
                    }
                    .environmentObject(inviteTravelService)
                    .environmentObject(tabViewStore)
                    .environmentObject(userTravelStore)
                }
            }
        } else {
            NavigationStack {
                SignInView()
            }
            .environmentObject(userService)
        }
    }
    
}

#Preview {
    ContentView()
}
