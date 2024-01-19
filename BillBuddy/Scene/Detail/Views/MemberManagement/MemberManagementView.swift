//
//  MemberManagementView.swift
//  BillBuddy
//
//  Created by 윤지호 on 2023/09/27.
//

import SwiftUI


struct MemberManagementView: View {
    @Environment(\.dismiss) var dismiss
    
    @StateObject private var joinMemberStore: JoinMemberStore = JoinMemberStore()
    @StateObject private var memberManagementVM: MemberManagementViewModel
    
    @EnvironmentObject private var settlementExpensesStore: SettlementExpensesStore
    @EnvironmentObject private var travelDetailStore: TravelDetailStore
    @EnvironmentObject private var userTravelStore: UserTravelStore
    
    init(travel: Travel, entryViewType: EntryViewType) {
        _memberManagementVM = StateObject(wrappedValue: MemberManagementViewModel(travel: travel, entryViewType: entryViewType))
    }
    
    var body: some View {
        
        VStack(spacing: 0) {
            List {
                VStack(alignment: .leading, spacing: 0) {
                    
                    Text("연결된 인원")
                        .listRowSeparator(.hidden)
                        .font(.body04)
                        .foregroundStyle(Color.gray600)
                        .padding(.top, 12)
                    Divider()
                        .listRowSeparator(.hidden)
                        .padding(.top, 9)
                        .padding(.bottom, 12)
                }
                .listRowSeparator(.hidden)
                
                ForEach(joinMemberStore.connectedMemebers) { member in
                    MemberCell(
                        memberManagementVM: memberManagementVM,
                        joinMemberStore: joinMemberStore,
                        member: member,
                        onEditing: {
                            joinMemberStore.selectMember(member.id)
                            memberManagementVM.isShowingEditSheet = true
                        },
                        onRemove: {
                            withAnimation {
                                joinMemberStore.removeMember(memberId: member.id)
                            }
                        }, 
                        saveAction: {
                            if memberManagementVM.entryViewType == .list {
                                userTravelStore.setTravelMember(travelId: memberManagementVM.travel.id, members: joinMemberStore.members)
                            }
                        }
                    )
                }
                .listRowSeparator(.hidden)
                
                VStack(alignment: .leading, spacing: 0) {
                    Text("더미 인원")
                        .listRowSeparator(.hidden)
                        .font(.body04)
                        .foregroundStyle(Color.gray600)
                        .padding(.top, 12)
                    Divider()
                        .listRowSeparator(.hidden)
                        .padding(.top, 9)
                        .padding(.bottom, 12)
                }
                .listRowSeparator(.hidden)
                
                ForEach(joinMemberStore.dummyMemebers) { member in
                    MemberCell(
                        memberManagementVM: memberManagementVM,
                        joinMemberStore: joinMemberStore,
                        member: member,
                        onEditing: {
                            joinMemberStore.selectMember(member.id)
                            memberManagementVM.isShowingEditSheet = true
                        },
                        onRemove: {
                            withAnimation {
                                joinMemberStore.removeMember(memberId: member.id)
                            }
                        }, 
                        saveAction: {
                            if memberManagementVM.entryViewType == .list {
                                userTravelStore.setTravelMember(travelId: memberManagementVM.travel.id, members: joinMemberStore.members)
                            }
                        }
                    )
                }
                .listRowSeparator(.hidden)
                VStack(alignment: .leading, spacing: 0) {
                    
                    Text("제외된 인원")
                        .listRowSeparator(.hidden)
                        .font(.body04)
                        .foregroundStyle(Color.gray600)
                        .padding(.top, 12)
                    Divider()
                        .listRowSeparator(.hidden)
                        .padding(.top, 9)
                        .padding(.bottom, 12)
                }
                .listRowSeparator(.hidden)
                
                ForEach(joinMemberStore.excludedMemebers) { member in
                    MemberCell(
                        memberManagementVM: memberManagementVM,
                        joinMemberStore: joinMemberStore,
                        member: member,
                        onEditing: {
                            joinMemberStore.selectMember(member.id)
                            memberManagementVM.isShowingEditSheet = true
                        },
                        onRemove: {
                            withAnimation {
                                joinMemberStore.removeMember(memberId: member.id)
                            }
                        }, 
                        saveAction: {
                            if memberManagementVM.entryViewType == .list {
                                userTravelStore.setTravelMember(travelId: memberManagementVM.travel.id, members: joinMemberStore.members)
                            }
                        }
                    )
                }
                .listRowSeparator(.hidden)
            }
            .listStyle(.inset)
            
            Button {
                withAnimation {
                    joinMemberStore.addMember()
                }
            } label: {
                Text("인원 추가")
                    .font(Font.body02)
            }
            .disabled(memberManagementVM.travel.isPaymentSettled)
            .frame(width: 332, height: 52)
            .background(memberManagementVM.travel.isPaymentSettled ? Color.gray400 : Color.myPrimary)
            .cornerRadius(12)
            .foregroundColor(.white)
            .padding(.bottom, 54)
            .animation(.easeIn(duration: 2), value: joinMemberStore.members)
        }
        .ignoresSafeArea(.all, edges: .bottom)
        .padding(.top, 3)
        .onAppear {
            if joinMemberStore.InitializedStore == false {
                joinMemberStore.initStore(travel: travelDetailStore.travel)
            }
            travelDetailStore.listenTravelDate { travel in
                joinMemberStore.initStore(travel: travelDetailStore.travel)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button(action: {
                    if joinMemberStore.isSelectedMember {
                        memberManagementVM.isShowingSaveAlert = true
                    } else {
                        memberManagementVM.dismissAction(settlementExpensesStore: settlementExpensesStore, travelDetailStore: travelDetailStore, joinMemberStore: joinMemberStore)
                        dismiss()
                    }
                }, label: {
                    Image("arrow_back")
                        .resizable()
                        .frame(width: 24, height: 24)
                })
                
            }
            
            ToolbarItem(placement: .principal) {
                Text("인원 관리")
                    .font(.title05)
                    .foregroundColor(Color.systemBlack)
            }
        }
        .alert(isPresented: $memberManagementVM.isShowingSaveAlert) {
            Alert(title: Text("변경사항을 저장하시겠습니까?"),
                  message: Text("뒤로가기 시 변경사항이 삭제됩니다."),
                  primaryButton: .destructive(Text("취소하고 나가기"), action: {
                memberManagementVM.dismissAction(settlementExpensesStore: settlementExpensesStore, travelDetailStore: travelDetailStore, joinMemberStore: joinMemberStore)
                dismiss()
            }),
                  secondaryButton: .default(Text("저장"), action: {
                Task {
                    await memberManagementVM.saveChange(joinMemberStore: joinMemberStore, userTravelStore: userTravelStore)
                    memberManagementVM.dismissAction(settlementExpensesStore: settlementExpensesStore, travelDetailStore: travelDetailStore, joinMemberStore: joinMemberStore)
                    dismiss()
                }
            }))
        }
        .sheet(isPresented: $memberManagementVM.isShowingEditSheet) {
            // onDismiss
        } content: {
            ZStack {
                MemberEditSheet(
                    memberManagementVM: memberManagementVM,
                    saveAction: {
                        Task {
                            await joinMemberStore.saveMemeber() {
                                if memberManagementVM.entryViewType == .list {
                                    userTravelStore.setTravelMember(travelId: memberManagementVM.travel.id, members: joinMemberStore.members)
                                }
                            }
                        }
                    }
                )
                .onAppear {
                    memberManagementVM.setMemberAndIsExcluded(m: joinMemberStore.members[joinMemberStore.selectedmemberIndex])
                }
            }
            .presentationDetents([.height(374)])
            .presentationDragIndicator(.hidden)
        }
        .sheet(isPresented: $memberManagementVM.isShowingShareSheet) {
            // onDismiss
        } content: {
            MemberShareSheet(joinMemberStore: joinMemberStore, memberManagementVM: memberManagementVM) {
                if memberManagementVM.entryViewType == .list {
                    userTravelStore.setTravelMember(
                        travelId: memberManagementVM.travel.id, 
                        members: joinMemberStore.members
                    )
                }
            }
                .presentationDetents([.large])
                .presentationDragIndicator(.hidden)
        }
    }
    
    
}
