//
//  DateManagementViewModel.swift
//  BillBuddy
//
//  Created by 김유진 on 1/20/24.
//

import Foundation
import Firebase
import FirebaseFirestore

final class DateManagementViewModel: ObservableObject {
    
    @Published var isPresentedDateSheet: Bool = false
    @Published var isPresentedSettledAlert: Bool = false
    @Published var isPresentedAlert: Bool = false
    @Published var travel: Travel
    @Published var paymentDates: [Date]
    let entryViewType: EntryViewType
    
    init(entryViewType: EntryViewType, travel: Travel, paymentDates: [Date]) {
        self.travel = travel
        self.paymentDates = paymentDates
        self.entryViewType = entryViewType
    }
    
    func getPaymentDates()  {
        if entryViewType == .list {
            Task {
                do {
                    let snapshot = try await Firestore.firestore()
                        .collection(StoreCollection.travel.path).document(travel.id)
                        .collection(StoreCollection.payment.path).getDocuments()
                    
                    let result = try snapshot.documents.map { try $0.data(as: Payment.self) }.map { $0.paymentDate.toDate() }
                    self.paymentDates = result
                    
                } catch {
                    print("false fetch payments - \(error)")
                }
            }
        }
    }
    
    func getDatesString() -> String {
        return "\(travel.startDate.toFormattedMonthAndDate()) - \(travel.endDate.toFormattedMonthAndDate())"
    }
    
    func getStartDate() -> Date {
        return travel.startDate.toDate()
    }
    
    func getEndDate() -> Date {
        return travel.endDate.toDate()
    }
    
    func checkPaymentsDate(calendarStore: DateManagementCalendarViewModel) {
        switch calendarStore.isDatesInRange(days: paymentDates) {
        case true:
            guard let firstDate = calendarStore.firstDate,
                  let secondDate = calendarStore.secondDate else { return }
            saveSelectedDate(firstDate: firstDate, secondDate: secondDate)
            isPresentedDateSheet = false
        case false:
            isPresentedAlert = true
        }
    }
    
    func saveSelectedDate(firstDate: Date, secondDate: Date) {
        Task {
            do {
                try await Firestore.firestore().collection(StoreCollection.travel.path).document(travel.id)
                    .setData([
                        "startDate" : firstDate.timeIntervalSince1970,
                        "endDate" : secondDate.timeIntervalSince1970
                    ], merge: true)
                // TODO: 이 부분 주석 지우기
//                userTravelStore.setTravelDate(travelId: travel.id, startDate: firstDate, endDate: secondDate)
//                travelDetailStore.setTravelDates(firstDate, secondDate)
                DispatchQueue.main.async {
                    self.travel.startDate = firstDate.timeIntervalSince1970
                    self.travel.endDate = secondDate.timeIntervalSince1970
                }
            } catch {
                print("false save date - \(error)")
            }
        }
    }
}
