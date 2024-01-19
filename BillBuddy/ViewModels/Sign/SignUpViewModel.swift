//
//  SignUpStore.swift
//  BillBuddy
//
//  Created by 박지현 on 2023/09/26.
//
import SwiftUI
import Firebase
import FirebaseFirestore
import FirebaseFirestoreSwift

final class SignUpViewModel: ObservableObject {
    @Published var signUpData = SignUpData()
    
    @Published var isNameTextError: Bool = false
    @Published var isEmailTextError: Bool = false
    @Published var isEmailInUseError: Bool = false
    @Published var isPasswordUnCorrectError: Bool = false
    @Published var isPasswordCountError: Bool = false
    @Published var isShowingCompleteJoinAlert: Bool = false
    @Published var isEmailValid = true
    @Published var isShowingProgressView: Bool = false
    
    func isPasswordEqual(passwordConfirm: String) {
        if signUpData.password == passwordConfirm {
            isPasswordUnCorrectError = false
        }
        else {
            isPasswordUnCorrectError = true
        }
    }
    
    func isValid() {
        isShowingProgressView = true
        
        let isNameValid = signUpData.name.count >= 2
        let isEmailValid = isValidEmailId(signUpData.email)
        
        emailCheck(email: signUpData.email) { isEmailInUse in
            let isPasswordValid = self.signUpData.password.count >= 6
            let isPasswordConfirmed = self.signUpData.passwordConfirm == self.signUpData.password
            let isTermOfUseAgreeValid = self.signUpData.isTermOfUseAgree
            let isPrivacyAgreeValid = self.signUpData.isPrivacyAgree
            
            if isNameValid && isEmailValid && isEmailInUse && isPasswordValid && isPasswordConfirmed && isTermOfUseAgreeValid && isPrivacyAgreeValid {
                self.isShowingCompleteJoinAlert = true
                
                Task {
                    if await self.postSignUp() {
                        // Success
                    } else {
                        print("실패")
                    }
                }
            } else {
                self.isNameTextError = !isNameValid
                self.isEmailTextError = !isEmailValid
                self.isEmailInUseError = !isEmailInUse
                self.isPasswordCountError = !isPasswordValid
                self.isPasswordUnCorrectError = !isPasswordConfirmed
            }
        }
    }
    
    func checkSignUp() -> Bool {
        if signUpData.name.isEmpty || signUpData.email.isEmpty || signUpData.password.isEmpty || signUpData.passwordConfirm.isEmpty || signUpData.isPrivacyAgree == false || signUpData.isTermOfUseAgree == false {
            return false
        }
        return true
    }
    
    // 이메일 형식
    public func isValidEmailId(_ emailText: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegex)
        return emailTest.evaluate(with: emailText)
    }
    
    // 이메일 중복 검사
    func emailCheck(email: String, completion: @escaping (Bool) -> Void) {
        let userDB = Firestore.firestore().collection(StoreCollection.user.path)
        let query = userDB.whereField("email", isEqualTo: email)
        
        query.getDocuments() { (qs, err) in
            if qs!.documents.isEmpty {
                print("데이터 중복 안 됨 가입 진행 가능")
                completion(true)
            } else {
                print("데이터 중복 됨 가입 진행 불가")
                completion(false)
            }
        }
    }
    
    func saveUserData(user: User) async throws {
        guard let userId = user.id else {
            return
        }
        
        do {
            try await FirestoreService.shared.saveDocument(collection: .user, documentId: userId, data: user)
            print(user)
        } catch {
            throw error
        }
    }
    
    @MainActor
    public func postSignUp() async -> Bool {
        do {
            let authResult = try await AuthService.shared.createUser(email: signUpData.email, password: signUpData.password )
            var user = signUpData.changeToUserModel(id: authResult.user.uid)
            user.reciverToken = UserService.shared.reciverToken
            try await saveUserData(user: user)
            
            UserDefaults.standard.setValue(authResult.user.uid, forKey: StoreCollection.user.path)
            return true
        } catch {
            self.isShowingCompleteJoinAlert = true
        }
        return false
    }
    
    
}

extension SignUpViewModel {
    struct SignUpData {
        var name: String = ""
        var email: String = ""
        var password: String = ""
        var passwordConfirm: String = ""

        
        var isPrivacyAgree: Bool = false
        var isTermOfUseAgree: Bool = false
        
        func changeToUserModel(id: String) -> User {
            return User(id: id, email: email, name: name, bankName: "", bankAccountNum: "", isPremium: false, premiumDueDate: Date(), reciverToken: "")
        }
    }

}
