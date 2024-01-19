//
//  SubView.swift
//  BillBuddy
//
//  Created by 윤지호 on 10/9/23.
//

import SwiftUI
import Kingfisher

struct MemberCell: View {
    @ObservedObject var memberManagementVM: MemberManagementViewModel
    @ObservedObject var joinMemberStore: JoinMemberStore
    
    var member: Travel.Member
    
    var onEditing: () -> Void
    var onRemove: () -> Void
    let saveAction: () -> Void
    
    var body: some View {
        HStack(spacing: 0) {
            if member.userImage != "" {
                KFImage(URL(string: member.userImage))
                    .placeholder {
                        ProgressView()
                            .frame(width: 40, height: 40)
                    }
                    .resizable()
                    .frame(width: 40, height: 40)
                    .clipShape(Circle())
            } else {
                Image(.defaultUser)
                    .resizable()
                    .frame(width: 40, height: 40)
            }
            
            VStack(alignment: .leading, spacing: 0) {
                Text(member.name)
                    .font(.body04)
                    .frame(height: 20)
                Text(member.advancePayment.wonAndDecimal)
                    .font(.body02)
                    .frame(height: 20)
            }
            .padding(.leading, 12)
            .foregroundColor(Color.systemBlack)
            
            Spacer()
            
            if member.inviteState != .invited {
                Button(member.inviteState.string) {
                    if member.inviteState == .dummy {
                        joinMemberStore.selectMember(member.id)
                        memberManagementVM.isShowingShareSheet = true
                    }
                    if member.inviteState == .wating {
                        joinMemberStore.cancelInvite(member.id) {
                            saveAction()
                        }
                    }
                }
                .frame(width: 80, height: 28)
                .background(member.inviteState == .dummy ? Color.myPrimaryLight : Color.myGreenLight)
                .clipShape(RoundedRectangle(cornerRadius: 15.5))
                .font(Font.caption02)
                .foregroundStyle(member.inviteState == .dummy ? Color.myPrimary : Color.myGreen)
                .padding(.trailing, 12)
            }
        }
        .frame(height: 40)
        .padding([.top, .bottom], 12)
        .swipeActions(edge: .trailing) {
            Button("삭제") {
                if memberManagementVM.travel.isPaymentSettled == false {
                    onRemove()
                    saveAction()
                }
            }
            .tint(Color.error)
            
            if member.inviteState != .wating {
                Button("수정") {
                    if memberManagementVM.travel.isPaymentSettled == false {
                        onEditing()
                        saveAction()
                    }
                }
                .tint(Color.gray500)
            }
        }
    }
}
