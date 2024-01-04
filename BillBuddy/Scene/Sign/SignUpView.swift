//
//  SignUp.swift
//  BillBuddy
//
//  Created by 윤지호 on 2023/09/22.
//

import SwiftUI

struct SignUpView: View {
    @Environment(\.dismiss) private var dismiss
    
    @StateObject private var signUpVM: SignUpViewModel = SignUpViewModel()
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("간편하게 가입하고\n서비스를 이용해보세요.")
                .font(.title05)
                .padding(.bottom, 24)
                .padding(.top, 17)
            
            ScrollView {
                VStack(alignment: .leading) {
                    TextField("이름을 입력해주세요.", text: $signUpVM.signUpData.name)
                        .padding(16)
                        .font(.body04)
                        .autocapitalization(.none)
                        .frame(width: 351, height: 52)
                        .background(RoundedRectangle(cornerRadius: 12)
                            .stroke(signUpVM.isNameTextError ? Color.error : Color.gray300, lineWidth: 2))
                        .cornerRadius(12)
                        .padding(.bottom, signUpVM.isNameTextError ? 0 : 12)
                        .focused(signUpVM.$isKeyboardUp)
                    
                    if signUpVM.isNameTextError {
                        Text("이름은 2자리 이상 입력해주세요.")
                            .font(.caption03)
                            .foregroundColor(.error)
                            .padding(.leading, 3)
                            .padding(.bottom, 12)
                    }
                    
                    TextField("이메일을 입력해주세요", text: $signUpVM.signUpData.email)
                        .padding(16)
                        .font(.body04)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .frame(width: 351, height: 52)
                        .background(RoundedRectangle(cornerRadius: 12)
                            .stroke(signUpVM.isEmailTextError || signUpVM.isEmailInUseError ? Color.error : Color.gray300, lineWidth: 2))
                        .cornerRadius(12)
                        .padding(.bottom, signUpVM.isEmailTextError || signUpVM.isEmailInUseError ? 0 : 12)
                        .focused(signUpVM.$isKeyboardUp)
                    
                    if signUpVM.isEmailTextError {
                        Text("정확한 이메일을 입력해주세요")
                            .font(.caption03)
                            .foregroundColor(.error)
                            .padding(.leading, 3)
                            .padding(.bottom, 12)
                    }
                    
                    if signUpVM.isEmailInUseError {
                        Text("이미 가입한 이메일 입니다.")
                            .font(.caption03)
                            .foregroundColor(.error)
                            .padding(.leading, 3)
                            .padding(.bottom, 12)
                    }
                    
                    SecureField("비밀번호를 입력해주세요", text: $signUpVM.signUpData.password)
                        .padding(16)
                        .font(.body04)
                        .autocapitalization(.none)
                        .frame(width: 351, height: 52)
                        .background(RoundedRectangle(cornerRadius: 12)
                            .stroke(signUpVM.isPasswordCountError ? Color.error : Color.gray300, lineWidth: 2))
                        .cornerRadius(12)
                        .padding(.bottom, signUpVM.isPasswordCountError ? 0 : 12)
                        .focused(signUpVM.$isKeyboardUp)
                    
                    if signUpVM.isPasswordCountError {
                        Text("비밀번호는 6자리 이상 입력해주세요")
                            .font(.caption03)
                            .foregroundColor(.error)
                            .padding(.leading, 3)
                            .padding(.bottom, 12)
                    }
                    
                    SecureField("비밀번호 확인", text:$signUpVM.signUpData.passwordConfirm)
                        .padding(16)
                        .font(.body04)
                        .autocapitalization(.none)
                        .frame(width: 351, height: 52)
                        .background(RoundedRectangle(cornerRadius: 12)
                            .stroke(signUpVM.isPasswordUnCorrectError ? Color.error : Color.gray300, lineWidth: 2))
                        .cornerRadius(12)
                        .padding(.bottom, signUpVM.isPasswordUnCorrectError ? 0 : 12)
                        .focused(signUpVM.$isKeyboardUp)
                    
                    if signUpVM.isPasswordUnCorrectError {
                        Text("비밀번호가 서로 다릅니다")
                            .font(.caption03)
                            .foregroundColor(.error)
                            .padding(.leading, 3)
                            .padding(.bottom, 12)
                    }
                }
                
                AgreementCheckButton(agreement: $signUpVM.signUpData.isTermOfUseAgree, text: "이용약관에 동의합니다.(필수)")
                AgreementCheckButton(agreement: $signUpVM.signUpData.isPrivacyAgree, text: "개인정보 취급방침에 동의합니다.(필수)")
                
                Spacer()
            }
            .scrollIndicators(.hidden)
            
            Group {
                Button(action: {
                    signUpVM.isShowingProgressView = true
                    
                    let isNameValid = signUpVM.signUpData.name.count >= 2
                    let isEmailValid = signUpVM.isValidEmailId(signUpVM.signUpData.email)
                    
                    signUpVM.emailCheck(email: signUpVM.signUpData.email) { isEmailInUse in
                        let isPasswordValid = signUpVM.signUpData.password.count >= 6
                        let isPasswordConfirmed = signUpVM.signUpData.passwordConfirm == signUpVM.signUpData.password
                        let isTermOfUseAgreeValid = signUpVM.signUpData.isTermOfUseAgree
                        let isPrivacyAgreeValid = signUpVM.signUpData.isPrivacyAgree
                        
                        if isNameValid && isEmailValid && isEmailInUse && isPasswordValid && isPasswordConfirmed && isTermOfUseAgreeValid && isPrivacyAgreeValid {
                            signUpVM.isShowingCompleteJoinAlert = true
                            
                            Task {
                                if await signUpVM.postSignUp() {
                                    // Success
                                } else {
                                    print("실패")
                                }
                            }
                        } else {
                            signUpVM.isNameTextError = !isNameValid
                            signUpVM.isEmailTextError = !isEmailValid
                            signUpVM.isEmailInUseError = !isEmailInUse
                            signUpVM.isPasswordCountError = !isPasswordValid
                            signUpVM.isPasswordUnCorrectError = !isPasswordConfirmed
                        }
                    }
                    
                }, label: {
                    Text("가입하기")
                        .font(.body02)
                        .foregroundColor(.white)
                        .frame(width: 351, height: 52)
                        .background(!signUpVM.checkSignUp() ? Color.gray400 : Color.myPrimary)
                        .cornerRadius(12)
                })
                .padding(.bottom, 20)
                .disabled(!signUpVM.checkSignUp() ? true : false)
                .alert("회원가입 완료", isPresented: $signUpVM.isShowingCompleteJoinAlert) {
                    Button("확인") {
                        dismiss()
                    }
                }
            }
        }
        .onTapGesture {
            signUpVM.isKeyboardUp = false
        }
        .padding(.horizontal, 24)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    dismiss()
                }) {
                    Image("arrow_back")
                        .resizable()
                        .frame(width: 24, height: 24)
                        .foregroundColor(.systemBlack)
                }
            }
        }
        
    }
}

#Preview {
    NavigationStack {
        SignUpView()
    }
}
