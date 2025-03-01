//
//  DeepLinkView.swift
//  BillBuddy
//
//  Created by 윤지호 on 10/18/23.
//

import SwiftUI

struct LodingView: View {
    @EnvironmentObject private var invitTravelService: InviteTravelService
    @EnvironmentObject private var tabViewStore: TabViewModel
    @EnvironmentObject private var userTravelStore: UserTravelStore

    var body: some View {
        VStack {
            Rectangle()
                .overlay(alignment: .center) {
                    Image(.billBuddy)
                }
                .foregroundStyle(Color.myPrimary)
                .ignoresSafeArea(.all)
                .alert("만료된 초대입니다.", isPresented: $invitTravelService.isShowingAlert) {
                    Button("확인") {
                        invitTravelService.removePushData()
                    }
                }
        }
        .onAppear {
            tabViewStore.popToRoow()
            invitTravelService.joinAndFetchTravel { travel in
                userTravelStore.fetchTravelCalculation()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4, execute: {
                    tabViewStore.pushView(type: .travel, travel: travel)
                })
            }
        }
    }
}

#Preview {
    LodingView()
        .environmentObject(InviteTravelService.shared)
        .environmentObject(TabViewModel.shared)
        .environmentObject(UserTravelStore())
}
