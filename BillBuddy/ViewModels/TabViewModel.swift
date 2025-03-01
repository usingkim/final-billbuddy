//
//  TabViewStore.swift
//  BillBuddy
//
//  Created by 윤지호 on 11/18/23.
//

import Foundation

final class TabViewModel: ObservableObject {
    
    static let shared = TabViewModel()
    private init() { }
    
    @Published var selectedTab: Int = 0 {
        didSet {
            switchTab()
        }
    }
    
    @Published var isPresentedDetail: Bool = false
    @Published var isPresentedChat: Bool = false
    @Published var isPresentedNoti: Bool = false
    @Published var isPresentedNotiList: Bool = false
    
    var isPresentedView: Bool {
        return isPresentedChat || isPresentedDetail
    }
    
    var seletedTravel: Travel?
    
    private func switchTab() {
        DispatchQueue.main.async {
            self.isPresentedDetail = false
            self.isPresentedChat = false
            self.isPresentedNoti = false
        }
    }
    
    @MainActor
    func pushView(type: NotiType, travel: Travel? = nil) {
        if let travel {
            seletedTravel = travel
        }
        switch type {
        case .travel, .invite:
            selectedTab = 0
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.isPresentedDetail = true
            }
        case .chatting:
            selectedTab = 1
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.isPresentedChat = true
            }
        case .notice:
            selectedTab = 2
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.isPresentedNoti = true
            }
        }
    }
    
    @MainActor
    func pushNotificationListView() {
        popToRoow()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.isPresentedNotiList = true
        }
    }
    
    @MainActor
    func popToRoow() {
        isPresentedDetail = false
        isPresentedChat = false
        isPresentedNoti = false
    }
}

