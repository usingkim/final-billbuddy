//
//  PaymentListView.swift
//  BillBuddy
//
//  Created by 윤지호 on 2023/09/22.
//

import SwiftUI


struct PaymentListView: View {
    @EnvironmentObject private var paymentService: PaymentServiceOrigin
    @EnvironmentObject private var travelDetailStore: TravelDetailStore
    @EnvironmentObject private var settlementExpensesStore: SettlementExpensesStore
    
    @ObservedObject var detailMainVM: DetailMainViewModel
    
    func uncheckedRadio(payment: Payment) -> some View {
        return Button {
            detailMainVM.addForDeletePayments(payment: payment)
        } label: {
            Image(.formCheckInputRadio)
        }
    }
    
    var body: some View {
        ForEach(detailMainVM.filteredPayments) { payment in
            HStack(spacing: 12){
                if detailMainVM.isEditing {
                    if detailMainVM.forDeletePayments.isEmpty {
                        uncheckedRadio(payment: payment)
                    }
                    
                    else if let index = detailMainVM.forDeletePayments.firstIndex(where: { $0.id == payment.id }) {
                        Button {
                            detailMainVM.forDeletePayments.remove(at: index)
                        } label: {
                            Image(.formCheckedInputRadio)
                        }
                    }
                    
                    else {
                        uncheckedRadio(payment: payment)
                    }
                }
                
                Image(payment.type.getImageString(type: .badge))
                    .resizable()
                    .frame(width: 40, height: 40)
                
                VStack(alignment: .leading, spacing: 0, content: {
                    Text(payment.content)
                        .font(.body03)
                        .foregroundStyle(Color.black)
                    HStack(spacing: 4) {
                        Image(.userSingleSvg)
                            .resizable()
                            .frame(width: 18, height: 18)
                        Text("\(payment.participants.count)명")
                            .font(.body04)
                            .foregroundStyle(Color.gray600)
                    }
                })
                
                Spacer()
                
                if !detailMainVM.isEditing {
                    VStack(alignment: .trailing) {
                        Text("₩\(payment.payment)")
                            .foregroundStyle(Color.black)
                            .font(.body02)
                        
                        if payment.participants.isEmpty {
                            Text("₩\(payment.payment)")
                                .foregroundStyle(Color.gray600)
                                .font(.caption02)
                        }
                        else {
                            Text("₩\(payment.payment / payment.participants.count)")
                                .foregroundStyle(Color.gray600)
                                .font(.caption02)
                        }
                    }
                }
            }
            .padding(.leading, 16)
            .padding(.trailing, 24)
            .swipeActions {
                if travelDetailStore.travel.isPaymentSettled == false {
                    Button(role: .destructive) {
                        detailMainVM.selectedPayment = payment
                        detailMainVM.isShowingDeletePaymentAlert = true
                    } label: {
                        Text("삭제")
                    }
                    .frame(width: 88)
                    .buttonStyle(.plain)
                    
                    
                    NavigationLink {
                        PaymentManageView(mode: .edit, payment: payment, travelCalculation: travelDetailStore.travel)
                            .environmentObject(paymentService)
                            .onDisappear {
                                detailMainVM.refresh(travelDetailStore: travelDetailStore, paymentStore: paymentService)
                            }
                    } label: {
                        Text("수정")
                    }
                    .frame(width: 88)
                    .background(Color.gray500)
                }
            }
            .onChange(of: detailMainVM.isEditing) { _ in
                if detailMainVM.isEditing == false {
                    detailMainVM.resetForDeletePayments()
                }
            }
            
        }
        .alert(isPresented: $detailMainVM.isShowingDeletePaymentAlert) {
            return Alert(title: Text(PaymentAlertText.paymentDelete), primaryButton: .destructive(Text("네"), action: {
                detailMainVM.deleteAPayment(paymentStore: paymentService, travelDetailStore: travelDetailStore, settlementExpensesStore: settlementExpensesStore)
            }), secondaryButton: .cancel(Text("아니오")))
        }
        .listRowInsets(nil)
        
    }
}
