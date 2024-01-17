//
//  OnboardingViewModel.swift
//  BillBuddy
//
//  Created by 김유진 on 1/16/24.
//

import SwiftUI

final class OnboardingViewModel: ObservableObject {

    @Published var nowState: OnboardingType = .firstTab
    
    let allcase = OnboardingType.allCases
    
    var firstTitle: String {
        nowState.firstTitle
    }
    
    var secondTitle: String {
        nowState.secondTitle
    }
    
    var description: String {
        nowState.description
    }
    
    var isLastOnboarding: Bool {
        nowState == OnboardingType.fourthTab
    }
    
    func changeState(isFirstEntry: Bool) -> Bool {
        switch nowState {
        case .firstTab:
            nowState = .secondTab
            return isFirstEntry
        case .secondTab:
            nowState = .thirdTab
            return isFirstEntry
        case .thirdTab:
            nowState = .fourthTab
            return isFirstEntry
        case .fourthTab:
            AuthStore.shared.isFirstEntry = false
            return false
        }
    }
    
    func setTabView() {
        UIPageControl.appearance().currentPageIndicatorTintColor = UIColor(Color.myPrimary)
        UIPageControl.appearance().pageIndicatorTintColor = UIColor(Color.gray200)
    }
    
    enum OnboardingType: String, Hashable, CaseIterable {
        case firstTab
        case secondTab
        case thirdTab
        case fourthTab
        
        var imageName: String {
            switch self {
            case .firstTab:
                return "onboarding1"
            case .secondTab:
                return "onboarding2"
            case .thirdTab:
                return "onboarding3"
            case .fourthTab:
                return "onboarding4"
            }
        }
        
        var firstTitle: String {
            switch self {
            case .firstTab:
                return "함께하는 여행"
            case .secondTab:
                return "동선 보며"
            case .thirdTab:
                return "카테고리별"
            case .fourthTab:
                return "일행들과 채팅방에서"
            }
        }
        var secondTitle: String {
            switch self {
            case .firstTab:
                return "지출내역을 N/1로 관리해요"
            case .secondTab:
                return "지출 및 일정 확인해요"
            case .thirdTab:
                return "자세한 지출 확인해요"
            case .fourthTab:
                return "자유롭게 소통해요"
            }
        }
        var description: String {
            switch self {
            case .firstTab:
                return "일행별 지출내역을 입력하고 관리할 수 있어요"
            case .secondTab:
                return "어디에서 얼마를 썼는지 동선을 보며 확인해요"
            case .thirdTab:
                return "전체 지출은 물론, 카테고리 별 지출을 확인할 수 있어요"
            case .fourthTab:
                return "채팅방에서 공유한 사진을 모아볼 수 있어요"
            }
        }
    }
    
}
