//
//  AddTravelView.swift
//  BillBuddy
//
//  Created by Ari on 2023/10/03.
//

import SwiftUI

struct AddTravelView: View {
    
    @EnvironmentObject private var tabBarVisivilyStore: TabBarVisivilyStore
    @EnvironmentObject var userTravelStore: UserTravelStore
    @Environment(\.dismiss) private var dismiss
    
    @StateObject private var addTravelVM: AddTravelViewModel = AddTravelViewModel()
    
    @FocusState private var isKeyboardUp: Bool
    
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    var body: some View {
        ZStack {
            Color.gray1000
            VStack(spacing: 0) {
                HStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.white)
                        .overlay(
                            TextField("여행 이름을 입력해주세요.", text: $addTravelVM.travelTitle)
                                .padding(12)
                                .focused($isKeyboardUp)
                        )
                }
                .font(.body04)
                .frame(maxWidth: .infinity)
                .frame(height: 52)
                .padding(.horizontal, 16)
                .padding(.top, 24)
                .shadow(color: Color.gray.opacity(0.3), radius: 8)
                
                HStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.white)
                        .shadow(color: Color.gray.opacity(0.3), radius: 8)
                        .overlay(
                            HStack {
                                Text("일정")
                                    .padding(.leading, 14)
                                
                                Spacer()
                                
                                Button(action: {
                                    hideKeyboard()
                                    addTravelVM.isShowingCalendarView.toggle()
                                }) {
                                    
                                    // CalendarSheetView의 firstDate와 endDate가 시차때문에 하루 전날로 표시돼서 
                                    if addTravelVM.startDate <= addTravelVM.endDate {
                                        let nineHoursInSeconds: TimeInterval = 9 * 60 * 60
                                        let adjustedStartDate = addTravelVM.startDate.addingTimeInterval(nineHoursInSeconds)
                                        let adjustedEndDate = addTravelVM.endDate.addingTimeInterval(nineHoursInSeconds)
                                        Text("\(adjustedStartDate.toFormattedMonthandDay()) - \(adjustedEndDate.toFormattedMonthandDay())")
                                            .font(.body04)
                                            .frame(width: 110, height: 30)
                                            .shadow(color: Color.clear, radius: 0)
                                        
                                            .foregroundColor(Color.myPrimary)
                                            .background(Color.lightBlue100)
                                            .cornerRadius(8)
                                    } else {
                                        Image("calendar-add-4")
                                            .resizable()
                                            .frame(width: 24, height: 24)
                                        
                                    }
                                }
                                .padding(.trailing, 14)
                                .shadow(color: Color.gray, radius: 0)
                                .sheet(isPresented: $addTravelVM.isShowingCalendarView) {
                                    CalendarSheetView(addTravelVM: addTravelVM)
                                        .environmentObject(userTravelStore)
                                        .presentationDetents([.height(560)])
                                }
                            }
                            
                        )
                }
                .font(.body04)
                .frame(maxWidth: .infinity)
                .frame(height: 52)
                .padding(.horizontal, 16)
                .padding(.top, 24)
                
                HStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.white)
                        .shadow(color: Color.gray.opacity(0.3), radius: 8)
                        .overlay(
                            HStack {
                                Text("인원")
                                    .padding(.leading, 16)
                                Spacer()
                                
                                Button(action: {
                                    hideKeyboard()
                                    addTravelVM.selectedMember = max(1, addTravelVM.selectedMember - 1)
                                }) {
                                    Image("Group 1171275315")
                                        .resizable()
                                        .frame(width: 24, height: 24)
                                }
                                .buttonStyle(.plain)
                                
                                Text("\(addTravelVM.selectedMember)")
                                    .font(.body01)
                                
                                Button(action: {
                                    hideKeyboard()
                                    addTravelVM.selectedMember += 1
                                }) {
                                    Image("Group 1171275314")
                                        .resizable()
                                        .frame(width: 24, height: 24)
                                }
                                .buttonStyle(.plain)
                                .padding(.trailing, 14)
                            }
                        )
                }
                .font(.body04)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .padding(.horizontal, 16)
                .padding(.top, 24)
                
                Spacer()
                
                Button {
                    userTravelStore.addTravel(addTravelVM.travelTitle, memberCount: addTravelVM.selectedMember, startDate: addTravelVM.startDate, endDate: addTravelVM.endDate)
                    dismiss()
                } label: {
                    Text("개설하기")
                        .font(.title05)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 60)
                .background(Color.myPrimary)
                .foregroundColor(.white)
                
            } //MARK: VSTACK
            .onTapGesture{
                isKeyboardUp = false
            }
            
        } //MARK: ZSTACK
        .overlay(
            Rectangle()
                .fill(Color.systemBlack.opacity(addTravelVM.isShowingCalendarView ? 0.5 : 0)).edgesIgnoringSafeArea(.all)
                .onTapGesture {
                    addTravelVM.isShowingCalendarView = false
                }
        )
        
        .navigationBarTitle("여행 추가하기")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar(tabBarVisivilyStore.visivility, for: .tabBar)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    dismiss()
                } label: {
                    Image(.arrowBack)
                        .resizable()
                        .frame(width: 24, height: 24)
                }
                
            }
        }
        .onAppear {
            tabBarVisivilyStore.hideTabBar()
        }
        .onTapGesture {
            hideKeyboard()
        }
        
    } //MARK: BODY
        
    
}

#Preview {
    NavigationStack {
        AddTravelView()
            .environmentObject(TabBarVisivilyStore())
            .environmentObject(UserTravelStore())
    }
}
