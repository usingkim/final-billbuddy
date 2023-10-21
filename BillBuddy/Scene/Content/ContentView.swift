//
//  ContentView.swift
//  BillBuddy
//
//  Created by 윤지호 on 2023/09/22.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var signInStore: SignInStore = SignInStore()
    @StateObject private var signUpStore: SignUpStore = SignUpStore()
    @StateObject private var userService: UserService = .shared
    @StateObject private var schemeServie: SchemeService = .shared
    @StateObject private var userTravelStore = UserTravelStore()
    @StateObject private var settlementExpensesStore = SettlementExpensesStore()
    @StateObject private var messageStore = MessageStore()
    @StateObject private var tabBarVisivilyStore = TabBarVisivilyStore()
    @StateObject private var notificationStore = NotificationStore()
    
    var body: some View {
        if AuthStore.shared.userUid != "" {
            if schemeServie.url == nil {
                BillBuddyTabView()
                    .environmentObject(settlementExpensesStore)
                    .environmentObject(userTravelStore)
                    .environmentObject(messageStore)
                    .environmentObject(userService)
                    .environmentObject(signInStore)
                    .environmentObject(signUpStore)
                    .environmentObject(tabBarVisivilyStore)
                    .environmentObject(notificationStore)
                    .environmentObject(schemeServie)
            } else {
                NavigationStack {
                    DeepLinkView()
                        .environmentObject(settlementExpensesStore)
                        .environmentObject(userTravelStore)
                        .environmentObject(messageStore)
                        .environmentObject(userService)
                        .environmentObject(signInStore)
                        .environmentObject(signUpStore)
                        .environmentObject(tabBarVisivilyStore)
                        .environmentObject(notificationStore)
                        .environmentObject(schemeServie)
                }
            }
        } else {
            NavigationStack {
                SignInView(signInStore: signInStore)
                    .environmentObject(signInStore)
                    .environmentObject(userService)
            }
        }
    }
}



#Preview {
    ContentView()
}
