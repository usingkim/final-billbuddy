//
//  ContentView.swift
//  BillBuddy
//
//  Created by 윤지호 on 2023/09/22.
//

import SwiftUI

struct ContentView: View {
    /* Service */
    @StateObject private var userService: UserService = .shared
    @StateObject private var inviteTravelService: InviteTravelService = .shared
    @StateObject private var notificationStore = NotificationService.shared
    @StateObject private var userTravelStore = UserTravelStore()
    @StateObject private var messageStore = MessageService()
    @StateObject private var myPageService = MyPageService()
    
    /* ViewModel */
    @StateObject private var settlementExpensesStore = SettlementExpensesStore()
    @StateObject private var tabViewStore = TabViewModel.shared
    @StateObject private var nativeViewModel = NativeAdViewModel()
    @StateObject private var adViewModel = AdViewModel()
    @StateObject private var tabBarVisibiltyStore = TabBarVisibilityStore()
    
    var body: some View {
        if AuthStore.shared.userUid != "" {
            if userService.isSignIn {
                if inviteTravelService.isLoading == false {
                    BillBuddyTabView()
                        .environmentObject(settlementExpensesStore)
                        .environmentObject(userTravelStore)
                        .environmentObject(messageStore)
                        .environmentObject(userService)
                        .environmentObject(tabBarVisibiltyStore)
                        .environmentObject(notificationStore)
                        .environmentObject(inviteTravelService)
                        .environmentObject(nativeViewModel)
                        .environmentObject(myPageService)
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
