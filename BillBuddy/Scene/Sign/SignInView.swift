//
//  SignIn.swift
//  BillBuddy
//
//  Created by 윤지호 on 2023/09/22.
//

import SwiftUI

struct SignInView: View {
    @StateObject private var signInVM: SignInViewModel = SignInViewModel()
    
    var body: some View {
        
        VStack(alignment: .leading) {
            Group {
                Text("간편하게 가입하고")
                Text("서비스를 이용해보세요.")
                    .padding(.bottom, 24)
            }
            .lineLimit(2)
            .font(.title04)
            VStack(spacing: 12) {
                TextField("이메일",text: $signInVM.emailText)
                    .padding(16)
                    .frame(width: 351, height: 52)
                    .overlay(RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.gray300, lineWidth: 1))
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .focused(signInVM.$isKeyboardUp)
                SecureField("비밀번호", text: $signInVM.passwordText)
                    .padding(16)
                    .frame(width: 351, height: 52)
                    .overlay(RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.gray300, lineWidth: 1))
                    .focused(signInVM.$isKeyboardUp)
            }
            
            Button(action: {
                Task {
                    if !(try await signInVM.checkSignIn()) {
                        signInVM.isShowingLoginResultAlert = true
                    }
                }
            }, label: {
                Text("로그인")
                    .font(.body02)
                    .foregroundColor(.white)
                    .frame(width: 351, height: 52)
                    .background(signInVM.emailText.isEmpty || signInVM.passwordText.isEmpty ? Color.gray400 : Color.myPrimary)
                    .cornerRadius(12)
            })
            .alert("로그인 결과", isPresented: $signInVM.isShowingLoginResultAlert) {
                Button("확인") {
                    signInVM.emailText = ""
                    signInVM.passwordText = ""
                }
            } message: {
                Text("로그인에 실패했습니다.")
            }
            .padding(.top, 20)
            
            HStack() {
                Spacer()
                NavigationLink {
                    SignUpView()
                } label: {
                    Text("이메일 가입")
                }
                
                Spacer()
                Divider()
                    .frame(height: 16)
                Spacer()
                
                NavigationLink {
                    ForgotPasswordView()
                } label: {
                    Text("비밀번호 찾기")
                }
                Spacer()
            }
            .font(.body04)
            .foregroundStyle(Color.systemBlack)
            .padding(.top, 20)
            .padding(.bottom, 30)
            
            VStack(alignment: .leading, spacing: 10) {
                Text("SNS계정으로 로그인")
                    .font(.body02)
                
                GoogleSignInView()
                AppleSignInView()
                
            }
        }
        .fullScreenCover(isPresented: $signInVM.isFirstEntry) {
            OnboardingView(isFirstEntry: $signInVM.isFirstEntry)
        }
        .onTapGesture {
            signInVM.isKeyboardUp = false
        }
        .onReceive(SNSSignInService.shared.$tempUser.receive(on: DispatchQueue.main), perform: { newValue in
            if let newValue {
                if newValue.name == "" {
                    signInVM.isShowingEmptyNameAlert.toggle()
                } else {
                    SNSSignInService.shared.signInUserFirstTime()
                }
            }
        })
        .padding(24)
        .onAppear {
            self.signInVM.isFirstEntry = AuthStore.shared.isFirstEntry
            signInVM.emailText = ""
            signInVM.passwordText = ""
        }
        .textFieldAlert(isPresented: $signInVM.isShowingEmptyNameAlert, textField: $signInVM.name, message: "이름을 입력하세요", isDismiss: false, action: {
            SNSSignInService.shared.tempUser?.name = signInVM.name
            SNSSignInService.shared.signInUserFirstTime()
        })
    }
}

#Preview {
    NavigationStack {
        SignInView()
    }
}
