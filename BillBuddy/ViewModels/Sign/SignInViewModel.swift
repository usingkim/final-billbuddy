//
//  SignInStore.swift
//  BillBuddy
//
//  Created by 박지현 on 2023/09/26.
//

import Foundation
import SwiftUI

final class SignInViewModel: ObservableObject {
    @Published var signInData = SignInData()
    
    @FocusState var isKeyboardUp: Bool
    
    @Published var emailText: String = ""
    @Published var passwordText: String = ""
    @Published var isSignedIn: Bool = false
    @Published var isShowingLoginResultAlert: Bool = false
    @Published var isDisableSignInButton: Bool = false
    @Published var alertDescription: String = ""
    @Published var isShowingEmptyNameAlert: Bool = false
    @Published var name: String = ""
    @Published var isFirstEntry = false
    
    @MainActor
    func checkSignIn() async throws -> Bool {
        isDisableSignInButton = true
        
        let result = try await AuthService.shared.signIn(email: emailText, password: passwordText)
        self.alertDescription = result.description
        
        switch result {
        case .signIn:
            isSignedIn = true
            return true
        default:
            isShowingLoginResultAlert = true
            return false
        }
    }
    
    func checkSignIn() -> Bool {
        if signInData.email.isEmpty || signInData.password.isEmpty {
            return false
        }
        return true
    }
    
}

extension SignInViewModel {
    struct SignInData {
        var id: String = UUID().uuidString
        var email: String = ""
        var password: String = ""
        
        func changeToUserModel(id: String) -> User {
            return User(id: id, email: email, name: "", bankName: "", bankAccountNum: "", isPremium: false, premiumDueDate: Date(), reciverToken: "")
        }
    }
}
