//
//  OnBoardingView.swift
//  BillBuddy
//
//  Created by 윤지호 on 12/20/23.
//

import SwiftUI

struct OnboardingView: View {
    @StateObject private var onboardingVM: OnboardingViewModel = OnboardingViewModel()
    @Binding var isFirstEntry: Bool

    var body: some View {
        VStack(spacing: 0) {
            Text(onboardingVM.firstTitle)
                .font(.title06)
                .padding(.top, 63)
                .padding(.bottom, 10)

            Text(onboardingVM.secondTitle)
                .font(.title06)
                .padding(.bottom, 10)

            Text(onboardingVM.description)
                .font(.body04)
                .padding(.bottom, 27)

            TabView(selection: $onboardingVM.nowState) {
                ForEach(onboardingVM.allcase, id: \.self) { state in
                    Image(state.imageName)
                        .resizable()
                }
                .frame(width: 195.84, height: 404)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .padding(.bottom, 20)

            TabView(selection: $onboardingVM.nowState) {
                ForEach(onboardingVM.allcase, id: \.self) { state in
                    Text("")
                }
            }
            .frame(height: 24)
            .tabViewStyle(.page(indexDisplayMode: .always))
            .padding(.bottom, 26)
            
            Button {
                isFirstEntry = onboardingVM.changeState(isFirstEntry: isFirstEntry)
            } label: {
                if onboardingVM.isLastOnboarding {
                    Text("빌버디 시작하기")
                        .font(Font.body02)
                }
                else {
                    Text("다음")
                        .font(Font.body02)
                }
            }
            .frame(width: 332, height: 52)
            .background(Color.myPrimary)
            .cornerRadius(12)
            .foregroundColor(.white)
            .padding(.bottom, 92)
        }
        .ignoresSafeArea(.all, edges: .bottom)
        .onAppear {
            onboardingVM.setTabView()
        }
    }
}

#Preview {
    OnboardingView(isFirstEntry: .constant(true))
}
