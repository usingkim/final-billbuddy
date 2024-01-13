//
//  TabBarVisibilityStore.swift
//  BillBuddy
//
//  Created by 윤지호 on 10/19/23.
//

import SwiftUI

final class TabBarVisibilityStore: ObservableObject {
    @Published var visibility: Visibility = .visible
    
    func hideTabBar() {
        visibility = .hidden
    }
    
    func showTabBar() {
        visibility = .visible
    }
    
}
