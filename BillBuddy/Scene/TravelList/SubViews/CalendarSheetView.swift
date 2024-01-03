//
//  CalendarSheetView.swift
//  BillBuddy
//
//  Created by Ari on 10/14/23.
//

import SwiftUI

struct CalendarSheetView: View {
    @EnvironmentObject private var userTravleStroe : UserTravelStore
    @ObservedObject var addTravelVM: AddTravelViewModel
    @StateObject var calendarVM = CalendarViewModel()
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            HStack {
                Button(action: {
                    calendarVM.selectBackMonth()
                }) {
                    Image("arrow_back")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 20, height: 20)
                }
                .padding(.trailing, 27)
                
                Text("\(calendarVM.titleForYear())   \(calendarVM.titleForMonth())")
                    .font(.body01)
                
                Button(action: {
                    calendarVM.selectForwardMonth()
                }) {
                    Image("arrow_forward_ios")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 20, height: 20)
                }
                .padding(.leading, 27)
            } //MARK: HSTACK
            .padding(.top, 27)
            .padding(.bottom, 34)
            
            VStack(spacing: 0) {
                HStack(spacing: 0) {
                    ForEach(calendarVM.days, id: \.self) { day in
                        Text(day)
                            .font(.body04)
                            .foregroundColor(.gray500)
                            .frame(height: 36)
                            .frame(maxWidth: .infinity)
                    }
                }
                .padding(.bottom, 12)
                
                VStack {
                    ForEach(calendarVM.weeks, id: \.self) { week in
                        ZStack {
                            HStack(spacing: 0) {
                                ForEach(week, id: \.self) { day in
                                    let isCurrentMonth = calendarVM.calendar.isDate(day, equalTo: calendarVM.date, toGranularity: .month)
                                    ZStack {
                                        fillRange(day: day, week: week, index: week.firstIndex(of: day)!)
                                        Button(action: {
                                            calendarVM.selectDay(day)
                                        }) {
                                            ZStack {
                                                Text("\(calendarVM.calendar.component(.day, from: day))")
                                                    .foregroundColor(isCurrentMonth ? (calendarVM.isDateSelected(day: day) ? Color.white : Color.black) : Color.gray500)
                                                    .foregroundColor(calendarVM.isDateSelected(day: day) ? Color.white : Color.black)
                                                
                                                Circle()
                                                    .frame(width: 4, height: 4)
                                                    .foregroundColor(calendarVM.isToday(day: day) ? (calendarVM.isDateSelected(day: day) ? Color.white : Color.myPrimary) : Color.clear)
                                                    .offset(y: 11.5)
                                            }
                                            .frame(width: 30, height: 30)
                                            .clipShape(Circle())
                                        }
                                        .background(calendarVM.isDateInRange(day: day) ? (calendarVM.isDateSelected(day: day) ? Color.myPrimary.cornerRadius(30) : Color.clear.cornerRadius(30)) : Color.clear.cornerRadius(30))
                                    }
                                    .frame(height: 36)
                                    .frame(maxWidth: .infinity)
                                }
                                .font(.caption02)
                            }
                        }
                    }
                }
                Spacer()
                
                Button(action: {
                    saveSelectedDate()
                }) {
                    Text(calendarVM.instructionText)
                        .foregroundColor(calendarVM.buttonFontColor)
                        .font(Font.body02)
                    
                }
                .disabled(calendarVM.instructionText != "여행 일정 선택 완료")
                .frame(width: 335, height: 52)
                .background(calendarVM.buttonBackgroundColor.cornerRadius(8))
                .foregroundColor(.white)
                .padding(.bottom, 52)
                
                
            } //MARK: VSTACK
            .padding(.vertical, 10)
            .padding(.horizontal, 20)
            
        } //MARK: BODY
    }
    
    func fillRange(day: Date, week: [Date], index: Int) -> some View {
        HStack(spacing: 0) {
            
            let rangeFrame = Rectangle()
                .fill(Color.lightBlue200)
                .frame(height: 30)
            
            if calendarVM.isDateSelected(day: day) {
                if day == calendarVM.firstDate {
                    Color.clear
                } else {
                    rangeFrame
                }
            } else {
                if calendarVM.isDateInRange(day: day) {
                    if index == 0 {
                        rangeFrame
                    } else {
                        if calendarVM.isFirstDayOfMonth(date: day) {
                            rangeFrame
                        } else {
                            rangeFrame
                        }
                    }
                } else {
                    Color.clear
                }
            }
            
            if calendarVM.isDateSelected(day: day) {
                if day == calendarVM.secondDate {
                    Color.clear
                } else {
                    if calendarVM.secondDate == nil {
                        Color.clear
                    } else {
                        rangeFrame
                    }
                }
            } else {
                if calendarVM.isDateInRange(day: day) {
                    if index == week.count - 1 {
                        rangeFrame
                    } else {
                        if calendarVM.isLastDayOfMonth(date: day) {
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
    
    func saveSelectedDate() {
        guard let firstDate = calendarVM.firstDate, let secondDate = calendarVM.secondDate else {
            return
        }
        
        addTravelVM.startDate = firstDate
        addTravelVM.endDate = secondDate
        
        addTravelVM.isShowingCalendarView = false
    }
}


