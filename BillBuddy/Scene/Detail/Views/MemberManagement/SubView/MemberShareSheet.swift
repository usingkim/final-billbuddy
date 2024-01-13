//
//  MemberShareSheet.swift
//  BillBuddy
//
//  Created by 윤지호 on 10/15/23.
//

import SwiftUI
import UIKit

struct MemberShareSheet: View {
    @Environment(\.dismiss) private var dismiss
    
    @EnvironmentObject private var notificationStore: NotificationService
    
    @ObservedObject var joinMemberStore: JoinMemberStore
    @ObservedObject var memberManagementVM: MemberManagementViewModel
    
    init(joinMemberStore: JoinMemberStore, memberManagementVM: MemberManagementViewModel, saveAction: @escaping () -> Void) {
        self.joinMemberStore = joinMemberStore
        self.memberManagementVM = memberManagementVM
        memberManagementVM.saveAction = saveAction
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                
                HStack(spacing: 0) {
                    Image(.search)
                        .resizable()
                        .frame(width: 24, height: 24)
                        .padding(.leading, 12)
                        .padding(.trailing, 8)
                    TextField("이름 또는 이메일을 입력해주세요", text: $memberManagementVM.searchText)
                        .textInputAutocapitalization(.never)
                        .font(.body04)
                        .onChange(of: memberManagementVM.searchText) { _ in
                            joinMemberStore.isfinishsearched = true
                        }
                        .onSubmit() {
                            if memberManagementVM.searchText.isEmpty == false {
                                joinMemberStore.searchUser(query: memberManagementVM.searchText)
                            }
                        }
                    
                    if !memberManagementVM.searchText.isEmpty {
                        Button(action: {
                            memberManagementVM.searchText = ""
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .frame(width: 24, height: 24)
                                .padding(.trailing, 12)
                        }
                    } else {
                        EmptyView()
                            .frame(width: 24, height: 24)
                    }
                }
                .frame(height: 40)
                .foregroundColor(.secondary)
                .background(Color(.secondarySystemBackground))
                .cornerRadius(12.0)
                .padding(.horizontal, 17)
                .padding(.top, 15)
                .padding(.bottom, 8)
                
                if joinMemberStore.isSearching == false {
                    if joinMemberStore.searchResult.isEmpty == false {
                        ForEach(joinMemberStore.searchResult) { user in
                            Button {
                                memberManagementVM.seletedUser = user
                                memberManagementVM.isShowingInviteAlert = true
                            } label: {
                                VStack(alignment: .leading, spacing: 0) {
                                    HStack(spacing: 0) {
                                        Image(.defaultUser)
                                            .resizable()
                                            .frame(width: 40, height: 40)
                                            .clipShape(Circle())
                                            .padding(.trailing, 12)
                                        Text(user.name)
                                            .foregroundStyle(Color.systemBlack)
                                            .padding(.trailing, 6)
                                        Text(user.email)
                                            .foregroundStyle(Color.gray600)
                                            .font(.body02)
                                        Spacer()
                                    }
                                    .font(.body04)
                                    
                                    .frame(height: 64)
                                }
                                .padding([.leading, .trailing], 24)
                                .foregroundColor(Color.systemBlack)
                            }
                            .alert(isPresented: $memberManagementVM.isShowingInviteAlert) {
                                Alert(title: Text("해당인원을 초대하시겠습다."),
                                      message: Text("모든 변경내용이 저장됩니다."),
                                      primaryButton: .destructive(Text("취소")),
                                      secondaryButton: .default(Text("초대"), action: {
                                    memberManagementVM.inviteMember(joinMemberStore: joinMemberStore, notificationStore: notificationStore)
                                }))
                            }
                        }
                    } else {
                        VStack {
                            if joinMemberStore.isfinishsearched == false && joinMemberStore.searchResult.isEmpty {
                                Text("'\(memberManagementVM.searchText)'에 대한 검색 결과가 없어요")
                                    .font(.body03)
                                    .foregroundStyle(Color.systemBlack)
                                
                            }
                        }
                        .padding(.top, 15)

                    }
                } else {
                    ProgressView()
                        .padding(.top, 25)
                }
            }
            Spacer()
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: {
                        dismiss()
                    }, label: {
                        Image("arrow_back")
                            .resizable()
                            .frame(width: 24, height: 24)
                    })
                }
                ToolbarItem(placement: .principal) {
                    Text("유저 초대하기")
                        .font(.title05)
                        .foregroundColor(Color.systemBlack)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    ShareLink(items: [joinMemberStore.getURL(memberId: joinMemberStore.seletedMember.id)]) {
                        Image(systemName: "square.and.arrow.up")
                    }
                    .foregroundStyle(Color.systemBlack)
                    
                }
            }
        }
        .onDisappear {
            joinMemberStore.searchResult = []
        }
     
    }
    
}
