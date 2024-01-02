//
//  SubPaymentView.swift
//  BillBuddy
//
//  Created by 김유진 on 9/29/23.
//

import SwiftUI

struct FillInPaymentInfoView: View {
    
    @ObservedObject var paymentManageVM: PaymentManageViewModel
    
    var focusedField: FocusState<PaymentFocusField?>.Binding
    
    var body: some View {
        ZStack {
            VStack(spacing: 16) {
                // 날짜
                datePickerSection
                // 분류
                typePickerSection
                // 내용
                contentSection
                // 가격
                priceSection
                // 인원
                PaymentMemberManagementView(mode: paymentManageVM.mode, priceString: $paymentManageVM.priceString, travelCalculation: $paymentManageVM.travelCalculation, members: $paymentManageVM.members, payment: $paymentManageVM.payment, selectedMember: $paymentManageVM.selectedMember, participants: $paymentManageVM.participants, isShowingMemberSheet: $paymentManageVM.isShowingMemberSheet)
            }
            .onTapGesture {
                hideKeyboard()
                paymentManageVM.isShowingDatePicker = false
                paymentManageVM.isShowingTimePicker = false
            }
            
            if paymentManageVM.isShowingDatePicker {
                datePickerView
            }
            
            
            if paymentManageVM.isShowingTimePicker {
                timePickerView
            }
        }
    }
    
}

extension FillInPaymentInfoView {
    var datePickerView: some View {
        DatePicker(selection: $paymentManageVM.paymentDate, in: paymentManageVM.travelCalculation.startDate.toDate()...paymentManageVM.travelCalculation.endDate.toDate(), displayedComponents: [.date], label: {
            Text("날짜")
                .font(.body02)
        })
        .labelsHidden()
        .datePickerStyle(.graphical)
        .background {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white)
        }
        .frame(width: 361, height: 400)
        .offset(y: 20)
    }
    
    var timePickerView: some View {
        DatePicker(selection: $paymentManageVM.paymentDate, in: paymentManageVM.travelCalculation.startDate.toDate()...paymentManageVM.travelCalculation.endDate.toDate(), displayedComponents: [.hourAndMinute], label: {
            Text("시간")
                .font(.body02)
        })
        .labelsHidden()
        .datePickerStyle(.wheel)
        .background {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white)
        }
        .frame(width: 198, height: 213)
        .offset(x: 20, y: -40)
    }
    
    var datePickerSection: some View {
        HStack(spacing: 4) {
            Text("날짜")
                .font(.body02)
                .padding(.leading, 16)
                .padding(.top, 16)
                .padding(.bottom, 20)
            
            Spacer()
            
            Button {
                paymentManageVM.isShowingDatePicker.toggle()
                if paymentManageVM.isShowingTimePicker {
                    paymentManageVM.isShowingTimePicker.toggle()
                }
            } label: {
                Text(paymentManageVM.paymentDate.datePickerDateFormat)
                    .font(.body04)
                    .padding(.leading, 11)
                    .padding(.top, 5)
                    .padding(.bottom, 5)
                    .padding(.trailing, 11)
                    .background {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.lightBlue100)
                    }
                    .foregroundStyle(paymentManageVM.isShowingDatePicker ? Color.myPrimary : Color.gray600)
            }
            
            
            Button {
                paymentManageVM.isShowingTimePicker.toggle()
                if paymentManageVM.isShowingDatePicker {
                    paymentManageVM.isShowingDatePicker.toggle()
                }
            } label: {
                Text(paymentManageVM.paymentDate.datePickerTimeFormat)
                    .font(.body04)
                    .padding(.leading, 11)
                    .padding(.top, 5)
                    .padding(.bottom, 5)
                    .padding(.trailing, 11)
                    .background {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.lightBlue100)
                    }
                    .foregroundStyle(paymentManageVM.isShowingTimePicker ? Color.myPrimary : Color.gray600)
            }
            .padding(.trailing, 16)
        }
        .background {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white)
        }
        .padding(.leading, 16)
        .padding(.top, 16)
        .padding(.trailing, 16)
        
    }
    var typePickerSection: some View {
        VStack {
            
            HStack{
                Text("분류")
                    .font(.body02)
                Spacer()
            }
            .padding(.leading, 16)
            .padding(.top, 16)
            .padding(.bottom, 20)
            
            HStack {
                Spacer()
                CategorySelectView(mode: .category, selectedCategory: $paymentManageVM.selectedCategory)
                Spacer()
            }
            .padding(.bottom, 30)
            .listRowSeparator(.hidden)
        }
        .background {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white)
        }
        .padding(.leading, 16)
        .padding(.trailing, 16)
        
    }
    var contentSection: some View {
        Section {
            
            HStack {
                Text("내용")
                    .font(.body02)
                TextField("내용을 입력해주세요", text: $paymentManageVM.expandDetails)
                    .multilineTextAlignment(.trailing)
                    .font(.body04)
                    .focused(focusedField, equals: .content)
            }
            .padding(.leading, 16)
            .padding(.top, 16)
            .padding(.bottom, 16)
            .padding(.trailing, 16)
        }
        .background {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white)
        }
        .padding(.leading, 16)
        .padding(.trailing, 16)
    }
    
    var priceSection: some View {
        Section {
            
            HStack {
                Text("결제금액")
                    .font(.body02)
                Spacer()
                
                
                TextField("결제금액을 입력해주세요", text: $paymentManageVM.priceString, onCommit: {
                    
                })
                    .keyboardType(.numberPad)
                    .multilineTextAlignment(.trailing)
                    .font(.body04)
                    .focused(focusedField, equals: .price)
                    .onTapGesture {
                        paymentManageVM.priceString = ""
                    }
            }
            .padding(.leading, 16)
            .padding(.top, 16)
            .padding(.bottom, 16)
            .padding(.trailing, 16)
        }
        .background {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white)
        }
        .padding(.leading, 16)
        .padding(.trailing, 16)
    }
}


extension FillInPaymentInfoView {
    
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
