//
//  DateSheet.swift
//  BillBuddy
//
//  Created by 김유진 on 10/9/23.
//

import SwiftUI

struct DateSheet: View {
    
    @ObservedObject var locationManager: LocationManager
    @ObservedObject var detailMainVM: DetailMainViewModel
    
    @State var startDate: Double
    @State var endDate: Double
    
    struct dateNumber: Hashable {
        var date: Date
        var dateNum: String
    }
    
    @State private var dates: [dateNumber] = []
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                HStack {
                    Button(action: {
                        detailMainVM.selectedDate = 0
                        locationManager.setAnnotations(filteredPayments: detailMainVM.filteredPayments)
                        detailMainVM.isShowingDateSheet.toggle()
                    }, label: {
                        Text("전체")
                            .font(.body01)
                    })
                    .buttonStyle(.plain)
                    
                    Spacer()
                }
                .padding(.bottom, 32)
                
                ForEach(dates, id:\.self) { date in
                    HStack {
                        Button(action: {
                            detailMainVM.selectedDate = date.date.timeIntervalSince1970
                            locationManager.setAnnotations(filteredPayments: detailMainVM.filteredPayments)
                            detailMainVM.isShowingDateSheet.toggle()
                        }, label: {
                            Text(date.date.dateWeek + " " + date.dateNum)
                                .font(.body01)
                        })
                        .buttonStyle(.plain)
                        .padding(.bottom, 32)
                        
                        Spacer()
                    }
                }
            }
        }
        
        .padding(.top, 48)
        .padding(.leading, 30)
        .onAppear {
            dates = startDateToEndDate(startDate: startDate, endDate: endDate)
        }
    }
    
    func startDateToEndDate(startDate: Double, endDate: Double)->[dateNumber] {
        var start = startDate
        var dates: [dateNumber] = []
        var day = 1
        
        while(start <= endDate) {
            dates.append(dateNumber(date: start.toDate(), dateNum: "\(day)일차"))
            start += 86400.0 // 하루치를 더해줌
            day += 1
        }
        
        return dates
    }
}
