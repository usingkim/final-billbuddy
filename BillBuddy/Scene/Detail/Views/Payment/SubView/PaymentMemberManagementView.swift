//
//  PaymentMemberManagementView.swift
//  BillBuddy
//
//  Created by 김유진 on 12/5/23.
//

import SwiftUI

struct PaymentMemberManagementView: View {
    
    @ObservedObject var paymentManageVM: PaymentManageViewModel
    
    var body: some View {
        Section {
            VStack(spacing: 0) {
                memberSection
                    .sheet(isPresented: $paymentManageVM.isShowingMemberSheet, content: {
                        memberSheet
                    })
                
                participantsListSection
            }
            .onAppear {
                paymentManageVM.setMember()
            }
        }
        .background {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white)
        }
        .padding(.leading, 16)
        .padding(.trailing, 16)
    }
    
    var memberSection: some View {
        HStack {
            Text("인원")
                .font(.body02)
                .padding(.top, 16)
                .padding(.leading, 16)
                .padding(.bottom, 17)
            Spacer()
            Button(action: {
                hideKeyboard()
                paymentManageVM.isShowingMemberSheet = true
            }, label: {
                HStack (spacing: 0) {
                    if paymentManageVM.members.isEmpty {
                        Text("추가하기")
                            .font(.body04)
                            .foregroundStyle(Color.gray600)
                    }
                    else if paymentManageVM.members.count == paymentManageVM.travelCalculation.members.count {
                        Text("모든 인원")
                            .font(.body04)
                            .foregroundStyle(Color.gray600)
                    }
                    else {
                        Text("수정하기")
                            .font(.body04)
                            .foregroundStyle(Color.gray600)
                    }
                    
                    Image("chevron_right")
                        .renderingMode(.template)
                        .resizable()
                        .frame(width: 24, height: 24)
                        .foregroundStyle(Color.gray600)
                    
                }
                .padding(.top, 14)
                .padding(.trailing, 16)
                .padding(.bottom, 15)
            })
            
        }
    }
    
    var memberSheet: some View {
        VStack {
            VStack(spacing: 0, content: {
                HStack {
                    Spacer()
                    
                    Button(action: {
                        paymentManageVM.tempMembers = paymentManageVM.travelCalculation.members
                    }, label: {
                        Text("전체 선택")
                    })
                    .font(.body03)
                    .foregroundStyle(Color.myPrimary)
                    
                    Text("/")
                    
                    Button(action: {
                        paymentManageVM.tempMembers = []
                    }, label: {
                        Text("전체 해제")
                    })
                    .font(.body03)
                    .foregroundStyle(Color.myPrimary)
                }
                .padding(.trailing, 32)
                .padding(.top, 32)
                
                ScrollView {
                    ForEach(paymentManageVM.travelCalculation.members) { member in
                        HStack {
                            Text(member.name)
                                .font(.body03)
                                .foregroundStyle(Color.black)
                            
                            Spacer()
                            
                            if paymentManageVM.tempMembers.firstIndex(where: { m in
                                m.id == member.id
                            }) != nil {
                                Image(.checked)
                                    .resizable()
                                    .frame(width: 24, height: 24)
                            }
                            else {
                                Image(.noneChecked)
                                    .resizable()
                                    .frame(width: 24, height: 24)
                            }
                        }
                        .padding(.leading, 32)
                        .padding(.trailing, 46)
                        .padding(.top, 36)
                        .onTapGesture {
                            paymentManageVM.addOrDeleteMember(member: member)
                        }
                    }
                    .onAppear {
                        paymentManageVM.tempMembers = paymentManageVM.members
                    }
                    .presentationDetents([.fraction(0.45)])
                }
                
                .padding(.top, 8)
            })
            
            
            Button {
                if paymentManageVM.mode == .edit {
                    paymentManageVM.editButton()
                }
                else {
                    paymentManageVM.addButton()
                }
            } label: {
                if paymentManageVM.mode == .edit {
                    Text("인원 수정")
                        .font(Font.body02)
                }
                else {
                    Text("인원 추가")
                        .font(Font.body02)
                }
            }
            .frame(width: 332, height: 52)
            .background(Color.myPrimary)
            .cornerRadius(12)
            .foregroundColor(.white)
            .padding(.bottom, 54)
        }
        .ignoresSafeArea(.all, edges: .bottom)
    }
    
    var participantsListSection: some View {
        ForEach(paymentManageVM.members) { member in
            Button(action: {
                paymentManageVM.selectedMember = member
                paymentManageVM.isShowingPersonalMemberSheet = true
            }, label: {
                HStack(spacing: 2) {
                    Text(member.name)
                        .font(.body04)
                        .padding(.leading, 16)
                        .padding(.top, 12)
                        .padding(.bottom, 12)
                    Spacer()
                    
                    if let idx = paymentManageVM.participants.firstIndex(where: { p in
                        p.memberId == member.id
                    }) {
                        Text("₩\(paymentManageVM.getPersonalPrice(idx: idx))")
                            .font(.body04)
                            .foregroundStyle(Color.gray600)
                    }
                    else {
                        Text("₩0")
                            .font(.body04)
                            .foregroundStyle(Color.gray600)
                    }
                    
                    Image("chevron_right")
                        .renderingMode(.template)
                        .resizable()
                        .frame(width: 24, height: 24)
                        .foregroundStyle(Color.gray600)
                        .padding(.trailing, 10)
                }
                .background {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.gray050)
                }
            })
            .buttonStyle(.plain)
            .padding(.leading, 16)
            .padding(.trailing, 10)
            .padding(.bottom, 8)
            .sheet(isPresented: $paymentManageVM.isShowingPersonalMemberSheet, onDismiss: {
                paymentManageVM.paidButton = false
                paymentManageVM.personalButton = false
            }) {
                ZStack {
                    personalPriceView
                        .onAppear(perform: {
                            paymentManageVM.getPersonalPrice()
                        })
                    if paymentManageVM.isShowingDescription {
                        descriptionOfPrice
                            .frame(width: 301, height: 226)
                            .background {
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.white)
                                    .shadow(radius: 6)
                            }
                            .offset(y: -10)
                    }
                }
                    .presentationDetents([.fraction(0.85)])
            }
        }
    }
    var descriptionOfPrice: some View {
        VStack(alignment: .leading, spacing: 0, content: {
            HStack(content: {
                Spacer()
                Button(action: {
                    paymentManageVM.isShowingDescription = false
                }, label: {
                    Image(.close)
                        .resizable()
                        .frame(width: 24, height: 24)
                        .padding(.trailing, 12)
                        .padding(.top, 12)
                    
                })
            })
            .padding(.bottom, 17)
            
            VStack(alignment: .leading, spacing: 0, content: {
                Text("먼저 지불한 금액")
                    .foregroundColor(Color.myPrimary)
                    .font(.body04)
                    + Text("은 전체 결제 금액에서 개인이 먼저 지불했던 금액이에요\n")
                    .font(.body04)
                
                Text("개인 사용 금액")
                    .foregroundColor(Color.myPrimary)
                    .font(.body04)
                    + Text("은 해당 인원의 금액을 따로 책정한 금액이에요\n")
                    .font(.body04)
                
                
                Text("입력하면 정산할 때 감안해서 계산해드려요")
                    .font(.body04)
                    
            })
            .frame(width: 253)
            .padding(.leading, 24)
            .padding(.trailing, 24)
            .padding(.bottom, 33)
        })
    }
    
    var personalPriceView: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("개인 항목 추가")
                .font(.title04)
                .padding(.bottom, 10)
            
            Text("일행 개인의 상세 지출을 입력해요")
                .font(.body01)
                .padding(.bottom, 30)
            
            Text("\(paymentManageVM.selectedMember.name)")
                .font(.body01)
                .padding(.bottom, 12)
            
            VStack(spacing: 0) {
                HStack(spacing: 0) {
                    Text("분류")
                        .font(.body02)
                    Button(action: {
                        paymentManageVM.isShowingDescription = true
                    }, label: {
                        Image(systemName: "info.circle")
                            .renderingMode(.template)
                            .frame(width: 24, height: 24)
                            .foregroundStyle(Color.positive)
                    })
                    
                    
                    Spacer()
                    Button {
                        paymentManageVM.paidButton.toggle()
                        if paymentManageVM.personalButton {
                            paymentManageVM.personalButton.toggle()
                        }
                    } label: {
                        Text("먼저 지불한 금액")
                            .font(.body02)
                            .padding(.top, 8)
                            .padding(.leading, 16)
                            .padding(.trailing, 16)
                            .padding(.bottom, 8)
                    }
                    .background {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.white)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(paymentManageVM.paidButton ? Color.myPrimary : Color.gray200, lineWidth: 1)
                            )
                    }
                    .foregroundStyle(paymentManageVM.paidButton ? Color.myPrimary : Color.gray200)
                    .padding(.trailing, 8)
                    
                    Button {
                        paymentManageVM.personalButton.toggle()
                        if paymentManageVM.paidButton {
                            paymentManageVM.paidButton.toggle()
                        }
                    } label: {
                        Text("개인 사용 금액")
                            .font(.body02)
                            .padding(.top, 8)
                            .padding(.leading, 16)
                            .padding(.trailing, 16)
                            .padding(.bottom, 8)
                    }
                    .background {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.white)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(paymentManageVM.personalButton ? Color.myPrimary : Color.gray200, lineWidth: 1)
                            )
                    }
                    .foregroundStyle(paymentManageVM.personalButton ? Color.myPrimary : Color.gray200)
                }
                .padding(.bottom, 26)
                
                HStack {
                    Text("금액")
                        .font(.body03)
                    
                    Spacer()
                    
                    if paymentManageVM.paidButton {
                        TextField("금액을 입력해주세요", text: $paymentManageVM.advanceAmountString)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                            .font(.body04)
                            .padding(.trailing, 14)
                            .onTapGesture {
                                paymentManageVM.advanceAmountString = ""
                            }
                    }
                    else if paymentManageVM.personalButton {
                        TextField("금액을 입력해주세요", text: $paymentManageVM.seperateAmountString)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                            .font(.body04)
                            .padding(.trailing, 14)
                            .onTapGesture {
                                paymentManageVM.seperateAmountString = ""
                            }
                    }
                    else {
                        Text("분류를 먼저 선택해주세요")
                            .font(.body04)
                            .foregroundColor(Color.gray500)
                            .padding(.trailing, 14)
                    }
                    
                }
                
                Divider()
                    .padding(.top, 20)
                    .padding(.bottom, 20)
                
                HStack {
                    Text("메모사항")
                        .font(.body03)
                    
                    Spacer()
                    
                    TextField("내용을 입력해주세요", text: $paymentManageVM.personalMemo)
                        .keyboardType(.numberPad)
                        .multilineTextAlignment(.trailing)
                        .font(.body04)
                        .onTapGesture {
                            paymentManageVM.personalMemo = ""
                        }
                        .padding(.trailing, 14)
                }
            }
            .padding(.top, 16)
            .padding(.leading, 15)
            .padding(.trailing, 14)
            .padding(.bottom, 16)
            .background {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.gray050)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.gray100, lineWidth: 1)
                    )
            }
            .padding(.bottom, 12)
            
            
            
            HStack {
                Text("정산 예정 금액")
                    .font(.body01)
                    .padding(.top, 15)
                    .padding(.leading, 16)
                    .padding(.bottom, 14)
                Spacer()
                Text("₩\((Int(paymentManageVM.seperateAmountString) ?? 0) - (Int(paymentManageVM.advanceAmountString) ?? 0))")
                    .font(.body01)
                    .padding(.top, 16)
                    .padding(.trailing, 16)
                    .padding(.bottom, 13)
            }
            .background {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.gray050)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.gray100, lineWidth: 1)
                    )
            }
            Spacer()
            Button {
                paymentManageVM.personalPrice()
            } label: {
                HStack {
                    Spacer()
                    Text("확인")
                        .foregroundColor(Color.white)
                        .font(.body02)
                    Spacer()
                }
                .padding(.top, 16)
                .padding(.bottom, 16)
            }
            .background {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.myPrimary)
            }
            .padding(.leading, 11)
            .padding(.trailing, 15)
            .padding(.bottom, 80)

        }
        .padding(.leading, 20)
        .padding(.top, 39)
        .padding(.trailing, 16)
        .onTapGesture {
            hideKeyboard()
        }
    }
}

extension PaymentMemberManagementView {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

