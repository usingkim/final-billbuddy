//
//  DateManagementCal.swift
//  BillBuddy
//
//  Created by 윤지호 on 12/16/23.
//

import SwiftUI
import Firebase
import FirebaseFirestore

struct DateManagementModifier: ViewModifier {
    @StateObject var dateManagementVM: DateManagementViewModel
    
    init(dateManagementVM: DateManagementViewModel) {
        _dateManagementVM = StateObject(wrappedValue: dateManagementVM)
    }

    func body(content: Content) -> some View {
        ZStack(alignment: .bottom) {
            content
            
            if dateManagementVM.isPresentedDateSheet {
                Rectangle()
                    .fill(.black.opacity(0.7))
                    .ignoresSafeArea()
                    .onTapGesture {
                        dateManagementVM.isPresentedDateSheet = false
                    }
                
                DateManagementCalendar(
                    dateManagementVM: dateManagementVM
                )
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .modifier(
            CheckDateModifier(isPresented: $dateManagementVM.isPresentedAlert)
        )
        .animation(
            dateManagementVM.isPresentedDateSheet ? .spring(response: 0.25) : .none,
            value: dateManagementVM.isPresentedDateSheet
        )
        
    }
}

struct DateManagementCalendar: View {
    
    @ObservedObject var dateManagementVM: DateManagementViewModel
    @StateObject private var calendarStore = EditDateCalenderStore()
    
    init(dateManagementVM: DateManagementViewModel) {
        self.dateManagementVM = dateManagementVM
    }
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Button(action: {
                    calendarStore.selectBackMonth()
                }) {
                    Image("arrow_back")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 20, height: 20)
                }
                .padding(.trailing, 27)
                
                Text("\(calendarStore.titleForYear())   \(calendarStore.titleForMonth())")
                    .font(.body01)
                
                Button(action: {
                    calendarStore.selectForwardMonth()
                }) {
                    Image("arrow_forward_ios")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 20, height: 20)
                }
                .padding(.leading, 27)
            } //MARK: HSTACK
            .padding(.top, 34)
            
            VStack(spacing: 3) {
                HStack(spacing: 0) {
                    ForEach(calendarStore.days, id: \.self) { day in
                        Text(day)
                            .font(.body04)
                            .foregroundColor(.gray500)
                            .frame(height: 36)
                            .frame(maxWidth: .infinity)
                    }
                    .padding(.top, 37)
                }
            }
            
            VStack(spacing: 6) {
              VStack(spacing: 6) {
                ForEach(calendarStore.weeks, id: \.self) { week in
                    ZStack {
                        HStack(spacing: 0) {
                            ForEach(week, id: \.self) { day in
                                let isCurrentMonth = calendarStore.calendar.isDate(day, equalTo: calendarStore.date, toGranularity: .month)
                                ZStack {
                                    fillRange(day: day, week: week, index: week.firstIndex(of: day)!)
                                    Button(action: {
                                        calendarStore.selectDay(day)
                                    }) {
                                        ZStack {
                                            Text("\(calendarStore.calendar.component(.day, from: day))")
                                                .foregroundColor(isCurrentMonth ? (calendarStore.isDateSelected(day: day) ? Color.white : Color.black) : Color.gray500)
                                                .foregroundColor(calendarStore.isDateSelected(day: day) ? Color.white : Color.black)
                                            
                                            Circle()
                                                .frame(width: 4, height: 4)
                                                .foregroundColor(calendarStore.isToday(day: day) ? (calendarStore.isDateSelected(day: day) ? Color.white : Color.myPrimary) : Color.clear)
                                                .offset(y: 11.5)
                                        }
                                        .frame(width: 30, height: 30)
                                        .clipShape(Circle())
                                    }
                                    .background(calendarStore.isDateInRange(day: day) ? (calendarStore.isDateSelected(day: day) ? Color.myPrimary.cornerRadius(30) : Color.clear.cornerRadius(30)) : Color.clear.cornerRadius(30))
                                }
                                .frame(height: 36)
                                .frame(maxWidth: .infinity)
                            }
                            .font(.caption02)
                        }
                    }
                }
              }
            }
            Spacer()
            Button(action: {
                dateManagementVM.checkPaymentsDate(calendarStore: calendarStore)
            }) {
                Text(calendarStore.seletedState.labelText)
                    .foregroundColor(calendarStore.isSelectedAll ? Color.white : Color.gray600)
                    .font(Font.body02)
            }
            .disabled(!calendarStore.isSelectedAll)
            .frame(width: 335, height: 52)
            .background(calendarStore.isSelectedAll ? Color.myPrimary.cornerRadius(8) : Color.gray100.cornerRadius(8))
            .foregroundColor(.white)
            .padding(.bottom, 52)
            
            
        } //MARK: VSTACK
        .padding(.vertical, 10)
        .padding(.horizontal, 20)
        .frame(height: 600)
        .background(Color.white)
        .clipShape(
            .rect(
                topLeadingRadius: 16,
                bottomLeadingRadius: 0,
                bottomTrailingRadius: 0,
                topTrailingRadius: 16
            )
        )
        .onAppear {
            calendarStore.setDate(dateManagementVM.getStartDate(), dateManagementVM.getEndDate())
        }
    } //MARK: BODY
    
    
    func fillRange(day: Date, week: [Date], index: Int) -> some View {
        HStack(spacing: 0) {
            let rangeFrame = Rectangle()
                .fill(Color.lightBlue200)
                .frame(height: 30)
            
            if calendarStore.isDateSelected(day: day) {
                if day == calendarStore.firstDate {
                    Color.clear
                } else {
                    rangeFrame
                }
            } else {
                if calendarStore.isDateInRange(day: day) {
                    if index == 0 {
                        rangeFrame
                    } else {
                        if calendarStore.isFirstDayOfMonth(date: day) {
                            rangeFrame
                        } else {
                            rangeFrame
                        }
                    }
                } else {
                    Color.clear
                }
            }
            
            if calendarStore.isDateSelected(day: day) {
                if day == calendarStore.secondDate {
                    Color.clear
                } else {
                    if calendarStore.secondDate == nil {
                        Color.clear
                    } else {
                        rangeFrame
                    }
                }
            } else {
                if calendarStore.isDateInRange(day: day) {
                    if index == week.count - 1 {
                        rangeFrame
                    } else {
                        if calendarStore.isLastDayOfMonth(date: day) {
                            rangeFrame
                        } else {
                            rangeFrame
                        }
                    }
                } else {
                    Color.clear
                }
            }
        }
    }
    
}


//#Preview {
//    DateManagementCalendar(isShowingCalendarView: .constant(true), saveAction: { _,_ in }, startDate: Date(), endDate: Date(), paymentDates: [])
//    
//}
