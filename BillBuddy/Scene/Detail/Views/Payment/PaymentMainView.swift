//
//  PaymentMainView.swift
//  BillBuddy
//
//  Created by 김유진 on 10/10/23.
//

import SwiftUI


struct PaymentMainView: View {
    
    @EnvironmentObject private var detailMainViewModel: DetailMainViewModel
    
    @EnvironmentObject private var paymentStore: PaymentStore
    @EnvironmentObject private var travelDetailStore: TravelDetailStore
    @EnvironmentObject private var settlementExpensesStore: SettlementExpensesStore
    
    @StateObject private var paymentMainViewModel: PaymentMainViewModel = PaymentMainViewModel()
    
    var body: some View {
        VStack(spacing: 0) {
            // 총 지출
            header
            // 카테고리 필터링 + 편집/편집 완료 버튼
            filteringSection
            // 지출 내역 리스트
            paymentList
            // 편집시 addPaymentButton 대신 editingPaymentDeleteButton을 내보여야함
            if !paymentMainViewModel.isEditing  {
                addPaymentButton
            }
            else {
                editingPaymentDeleteButton
            }
        }
        .onAppear {
            Task {
                await detailMainViewModel.fetchAll()
            }
        }
    }
}

extension PaymentMainView {
    
    var header: some View {
        VStack(spacing: 0) {
            Group {
                HStack(spacing: 0) {
                    VStack(alignment: .leading, spacing: 4, content: {
                        Text("총 지출")
                            .font(.body04)
                            .padding(.trailing, 9)
                        
                        Text(settlementExpensesStore.settlementExpenses.totalExpenditure.wonAndDecimal)
                            .font(.body01)
                    })
                    .padding(.top, 18)
                    .padding(.leading, 15)
                    .padding(.bottom, 15)
                    
                    Spacer()
                    
                    NavigationLink {
                        SettledAccountView(entryViewtype: .more)
                            .environmentObject(travelDetailStore)
                    } label: {
                        Text(travelDetailStore.travel.isPaymentSettled ? "정산내역": "정산하기")
                            .font(.body04)
                            .foregroundStyle(Color.gray600)
                    }
                    
                    .frame(width: 71, height: 30, alignment: .center)
                    .background {
                        RoundedRectangle(cornerRadius: 21)
                            .fill(Color.white)
                    }
                    .padding(.trailing, 18)
                }
            }
            .frame(height: 80)
            .background {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.gray050)
            }
            .padding(.leading, 16)
            .padding(.trailing, 16)
            .padding(.bottom, 32)
        }
        .onChange(of: detailMainViewModel.selectedDate) { _ in
            paymentMainViewModel.selectedCategory = nil
        }
    }
    
    var editingPaymentDeleteButton: some View {
        Button(action: {
            paymentMainViewModel.isShowingDeletePayment = true
        }, label: {
            PaymentButtonView(scale: .big, text: "삭제하기")
        })
        .alert(isPresented: Binding<Bool>(
            get: { paymentMainViewModel.isShowingDeletePayment },
            set: { paymentMainViewModel.isShowingDeletePayment = $0 }
        )) {
            return Alert(title: Text(PaymentAlertText.selectedPaymentDelete), primaryButton: .destructive(Text("네"), action: {
                detailMainViewModel.deleteSelectedPayments()
                paymentMainViewModel.isEditing.toggle()
            }), secondaryButton: .cancel(Text("아니오"), action: {
                paymentMainViewModel.isEditing.toggle()
            }))
        }
    }
    
    var addPaymentButton: some View {
        NavigationLink {
            PaymentManageView(mode: .add, travelCalculation: travelDetailStore.travel)
                .environmentObject(paymentStore)
                .onDisappear {
                    if travelDetailStore.isChangedTravel {
                        paymentMainViewModel.selectedCategory = nil
                        detailMainViewModel.selectedDate = 0
                    }
                }
        } label: {
            HStack(spacing: 12) {
                Spacer()
                Image("add payment")
                    .resizable()
                    .frame(width: 28, height: 28)
                
                Text(travelDetailStore.travel.isPaymentSettled ? "정산 완료 여행" : "지출 내역 추가")
                    .font(.body04)
                    .foregroundStyle(Color.gray600)
                
                Spacer()
            }
            .padding(.top, 12)
            .padding(.bottom, 12)
        }
        .disabled(travelDetailStore.travel.isPaymentSettled)
        .background {
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray100, lineWidth: 1)
        }
        .padding(.leading, 16)
        .padding(.trailing, 16)
    }
    
    var paymentList: some View {
        VStack(spacing: 0) {
            if detailMainViewModel.isFetchingList {
                HStack {
                    Spacer()
                    ProgressView()
                        .padding(.top, 59)
                    Spacer()
                }
                Spacer()
            }
            else if detailMainViewModel.filteredPayments.isEmpty {
                HStack {
                    Spacer()
                    Text("지출을 추가해주세요")
                        .foregroundStyle(Color.gray600)
                        .font(.body02)
                        .padding(.top, 59)
                    Spacer()
                }
                Spacer()
            }
            else {
                List {
                    PaymentListView(paymentStore: paymentStore, isEditing: Binding<Bool>(
                        get: { paymentMainViewModel.isEditing },
                        set: { paymentMainViewModel.isEditing = $0 }
                    ), forDeletePayments: Binding<[Payment]>(
                        get: { detailMainViewModel.forDeletePayments },
                        set: { detailMainViewModel.forDeletePayments = $0}
                    ))
                        .padding(.bottom, 12)
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets())
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
            }
        }
    }
    
    var filteringSection: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                Button(action: {
                    paymentMainViewModel.isShowingSelectCategorySheet = true
                }, label: {
                    if let category = paymentMainViewModel.selectedCategory {
                        Text(category.rawValue)
                            .font(.body04)
                            .foregroundStyle(Color.gray600)
                    }
                    else {
                        Text("전체내역")
                            .font(.body04)
                            .foregroundStyle(Color.gray600)
                    }
                    Image("expand_more")
                        .renderingMode(.template)
                        .resizable()
                        .frame(width: 24, height: 24)
                        .foregroundStyle(Color.gray600)
                })
                .sheet(isPresented: Binding<Bool>(
                    get: { paymentMainViewModel.isShowingSelectCategorySheet },
                    set: { paymentMainViewModel.isShowingSelectCategorySheet = $0 }
                )) {
                    CategorySelectView(mode: .sheet, selectedCategory: Binding<Payment.PaymentType?>(
                        get: { paymentMainViewModel.selectedCategory },
                        set: { paymentMainViewModel.selectedCategory = $0 }
                    ))
                        .presentationDetents([.fraction(0.3)])
                }
                
                .onChange(of: paymentMainViewModel.selectedCategory, perform: { category in
                    
                    // 날짜 전체일때
                    if detailMainViewModel.selectedDate == 0 {
                        // 선택된 카테고리가 있을때
                        if let category = paymentMainViewModel.selectedCategory {
                            detailMainViewModel.filterCategory(category: category)
                        }
                        // 카테고리 전체
                        else {
                            detailMainViewModel.resetFilter()
                            paymentMainViewModel.selectedCategory = nil
                        }
                    }
                    else {
                        if let category = paymentMainViewModel.selectedCategory{
                            detailMainViewModel.filterDateCategory(category: category)
                        }
                        else {
                            paymentMainViewModel.selectedCategory = nil
                            detailMainViewModel.filterDate()
                        }
                    }
                })
                
                Spacer()
                
                Button(action: {
                    paymentMainViewModel.isEditing.toggle()
                }, label: {
                    if paymentMainViewModel.isEditing {
                        Text("편집 완료")
                            .font(.body04)
                            .foregroundStyle(Color.gray600)
                    }
                    else {
                        Text("편집")
                            .font(.body04)
                            .foregroundStyle(Color.gray600)
                    }
                })
                .disabled(travelDetailStore.travel.isPaymentSettled)
            }
            .padding(.leading, 17)
            .padding(.trailing, 20)
            .padding(.bottom, 9)
            
            Divider()
                .padding(.leading, 16)
                .padding(.trailing, 16)
                .padding(.bottom, 16)
        }
    }
}
