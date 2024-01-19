//
//  DateManagementCal.swift
//  BillBuddy
//
//  Created by 윤지호 on 12/16/23.
//

import SwiftUI

struct DateManagementCalendarView: View {
    
    @ObservedObject var dateManagementVM: DateManagementViewModel
    @StateObject private var dateManagementCalendarVM = DateManagementCalendarViewModel()
    
    init(dateManagementVM: DateManagementViewModel) {
        self.dateManagementVM = dateManagementVM
    }
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Button(action: {
                    dateManagementCalendarVM.selectBackMonth()
                }) {
                    Image("arrow_back")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 20, height: 20)
                }
                .padding(.trailing, 27)
                
                Text("\(dateManagementCalendarVM.titleForYear())   \(dateManagementCalendarVM.titleForMonth())")
                    .font(.body01)
                
                Button(action: {
                    dateManagementCalendarVM.selectForwardMonth()
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
                    ForEach(dateManagementCalendarVM.days, id: \.self) { day in
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
                ForEach(dateManagementCalendarVM.weeks, id: \.self) { week in
                    ZStack {
                        HStack(spacing: 0) {
                            ForEach(week, id: \.self) { day in
                                let isCurrentMonth = dateManagementCalendarVM.calendar.isDate(day, equalTo: dateManagementCalendarVM.date, toGranularity: .month)
                                ZStack {
                                    fillRange(day: day, week: week, index: week.firstIndex(of: day)!)
                                    Button(action: {
                                        dateManagementCalendarVM.selectDay(day)
                                    }) {
                                        ZStack {
                                            Text("\(dateManagementCalendarVM.calendar.component(.day, from: day))")
                                                .foregroundColor(isCurrentMonth ? (dateManagementCalendarVM.isDateSelected(day: day) ? Color.white : Color.black) : Color.gray500)
                                                .foregroundColor(dateManagementCalendarVM.isDateSelected(day: day) ? Color.white : Color.black)
                                            
                                            Circle()
                                                .frame(width: 4, height: 4)
                                                .foregroundColor(dateManagementCalendarVM.isToday(day: day) ? (dateManagementCalendarVM.isDateSelected(day: day) ? Color.white : Color.myPrimary) : Color.clear)
                                                .offset(y: 11.5)
                                        }
                                        .frame(width: 30, height: 30)
                                        .clipShape(Circle())
                                    }
                                    .background(dateManagementCalendarVM.isDateInRange(day: day) ? (dateManagementCalendarVM.isDateSelected(day: day) ? Color.myPrimary.cornerRadius(30) : Color.clear.cornerRadius(30)) : Color.clear.cornerRadius(30))
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
                dateManagementVM.checkPaymentsDate(calendarStore: dateManagementCalendarVM)
            }) {
                Text(dateManagementCalendarVM.seletedState.labelText)
                    .foregroundColor(dateManagementCalendarVM.isSelectedAll ? Color.white : Color.gray600)
                    .font(Font.body02)
            }
            .disabled(!dateManagementCalendarVM.isSelectedAll)
            .frame(width: 335, height: 52)
            .background(dateManagementCalendarVM.isSelectedAll ? Color.myPrimary.cornerRadius(8) : Color.gray100.cornerRadius(8))
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
            dateManagementCalendarVM.setDate(dateManagementVM.getStartDate(), dateManagementVM.getEndDate())
        }
    } //MARK: BODY
    
    
    func fillRange(day: Date, week: [Date], index: Int) -> some View {
        HStack(spacing: 0) {
            let rangeFrame = Rectangle()
                .fill(Color.lightBlue200)
                .frame(height: 30)
            
            if dateManagementCalendarVM.isDateSelected(day: day) {
                if day == dateManagementCalendarVM.firstDate {
                    Color.clear
                } else {
                    rangeFrame
                }
            } else {
                if dateManagementCalendarVM.isDateInRange(day: day) {
                    if index == 0 {
                        rangeFrame
                    } else {
                        if dateManagementCalendarVM.isFirstDayOfMonth(date: day) {
                            rangeFrame
                        } else {
                            rangeFrame
                        }
                    }
                } else {
                    Color.clear
                }
            }
            
            if dateManagementCalendarVM.isDateSelected(day: day) {
                if day == dateManagementCalendarVM.secondDate {
                    Color.clear
                } else {
                    if dateManagementCalendarVM.secondDate == nil {
                        Color.clear
                    } else {
                        rangeFrame
                    }
                }
            } else {
                if dateManagementCalendarVM.isDateInRange(day: day) {
                    if index == week.count - 1 {
                        rangeFrame
                    } else {
                        if dateManagementCalendarVM.isLastDayOfMonth(date: day) {
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
