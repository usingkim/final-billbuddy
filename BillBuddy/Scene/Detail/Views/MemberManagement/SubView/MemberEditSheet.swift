//
//  MemberEditSheet.swift
//  BillBuddy
//
//  Created by 윤지호 on 10/15/23.
//

import SwiftUI

struct MemberEditSheet: View {
    @ObservedObject var memberManagementVM: MemberManagementViewModel
    @FocusState private var isKeyboardUp: Bool
    
    let saveAction: () -> Void
    
    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(Color.gray050, lineWidth: 1)
                .frame(width: 329, height: 52)
                .background(Color.gray100)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay {
                    HStack {
                        Text("닉네임")
                            .font(.body02)
                        TextField(memberManagementVM.member.name, value: $memberManagementVM.nickName, formatter: NumberFormatter.numberFomatter)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                            .font(Font.body04)
                            .focused($isKeyboardUp)
                    }
                    .padding([.leading, .trailing], 16)
                }
                .padding(.top, 47)
                .padding(.bottom, 16)
            
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(Color.gray050, lineWidth: 1)
                .frame(width: 329, height: 52)
                .background(Color.gray100)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay {
                    HStack {
                        Text("선금")
                            .font(.body02)
                        TextField(memberManagementVM.member.advancePayment.wonAndDecimal, text: $memberManagementVM.advancePayment)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                            .font(Font.body04)
                            .focused($isKeyboardUp)
                    }
                    .padding([.leading, .trailing], 16)
                }
                .padding(.bottom, 16)

            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(Color.gray050, lineWidth: 1)
                .frame(width: 329, height: 52)
                .background(Color.gray100)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay {
                    HStack {
                        Text("지불 제외 여부")
                            .font(.body02)
                        Spacer()
                        Button {
                            memberManagementVM.isExcluded.toggle()
                        } label: {
                            Image(memberManagementVM.isExcluded ? .checked : .noneChecked)
                        }
                    }
                    .padding([.leading, .trailing], 16)
                }
            Spacer()
            
            Button {
                memberManagementVM.setMemeber()
                saveAction()
            } label: {
                Text("수정 완료")
                    .font(Font.body02)
            }
            .frame(width: 332, height: 52)
            .background(Color.myPrimary)
            .cornerRadius(12)
            .foregroundColor(.white)
            .padding(.bottom, 54)
        }
        .onTapGesture {
            DispatchQueue.main.async {
                self.isKeyboardUp = false
            }
        }
    }
}

