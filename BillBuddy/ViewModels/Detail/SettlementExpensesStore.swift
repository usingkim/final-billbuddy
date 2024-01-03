//
//  SettlementExpensesStore.swift
//  BillBuddy
//
//  Created by 윤지호 on 10/6/23.
//

import Foundation

final class SettlementExpensesStore: ObservableObject {
    @Published var settlementExpenses = SettlementExpenses()
    
    private var payments: [Payment] = []
    
    func getPaymentsOfType(type: SpendingType) -> [Payment] {
        switch type {
        case .totalExpenditure:
            return payments
        case .todayExpenditure:
            return payments.filter { payment in
                return Date(timeIntervalSince1970: payment.paymentDate).dateAndTime == Date().dateAndTime
            }
        case .totalTransportation:
            return payments.filter { $0.type == .transportation }
        case .totalAccommodation:
            return payments.filter { $0.type == .accommodation }
        case .totalTourism:
            return payments.filter { $0.type == .tourism }
        case .totalFood:
            return payments.filter { $0.type == .food }
        case .totalEtc:
            return payments.filter { $0.type == .etc }
        case .personalSettlement:
            return settlementExpenses.members.map { Payment(id: UUID().uuidString, type: .accommodation, content: $0.memberData.name, payment: $0.lastDividedAmount, address: .init(address: "", latitude: 0, longitude: 0), participants: [], paymentDate: 0.0)}
        }
    }
    
    @MainActor
    func setSettlementExpenses(payments: [Payment], members: [TravelCalculation.Member]) {
        self.payments = payments
        var newExpenses = SettlementExpenses()
        newExpenses.totalExpenditure = payments.reduce(0, { $0 + $1.payment } )
        newExpenses.totalTransportation = payments.filter{ $0.type == .transportation }.reduce(0, { $0 + $1.payment } )
        newExpenses.totalAccommodation = payments.filter{ $0.type == .accommodation }.reduce(0, { $0 + $1.payment } )
        newExpenses.totalTourism = payments.filter{ $0.type == .tourism }.reduce(0, { $0 + $1.payment } )
        newExpenses.totalFood = payments.filter{ $0.type == .food }.reduce(0, { $0 + $1.payment } )
        newExpenses.totalEtc = payments.filter{ $0.type == .etc }.reduce(0, { $0 + $1.payment } )
        
        newExpenses.members = members.map { SettlementExpenses.MemberPayment(memberData: $0, totalParticipationAmount: 0, personaPayment: 0, advancePayment: $0.advancePayment) }
        
        for payment in payments {
            var seperate: [Int] = [0, 0]
            for participant in payment.participants {
                if participant.seperateAmount != 0 {
                    seperate[0] += 1
                    seperate[1] += participant.seperateAmount
                }
            }
            
            for participant in payment.participants {
                guard let index = members.firstIndex(where: { $0.id == participant.memberId } ) else {
                    continue
                }
                
                if participant.seperateAmount != 0 {
                    newExpenses.members[index].totalParticipationAmount += participant.seperateAmount
                }
                else {
                    newExpenses.members[index].totalParticipationAmount += ((payment.payment - seperate[1]) / (payment.participants.count - seperate[0]))
                }
                
                newExpenses.members[index].totalParticipationAmount -= participant.advanceAmount
            }
        }
        
        settlementExpenses = newExpenses
    }
    
    func addExpenses(payment: Payment) {
        settlementExpenses.totalExpenditure += payment.payment
        
        switch payment.type {
        case .transportation:
            settlementExpenses.totalTransportation += payment.payment
        case .accommodation:
            settlementExpenses.totalAccommodation += payment.payment
        case .tourism:
            settlementExpenses.totalTourism += payment.payment
        case .food:
            settlementExpenses.totalFood += payment.payment
        case .etc:
            settlementExpenses.totalEtc += payment.payment
        }
        
        resetExpense(payment: payment)
    }
    
    func removeExpenses(payment: Payment) {
        settlementExpenses.totalExpenditure -= payment.payment
        
        switch payment.type {
        case .transportation:
            settlementExpenses.totalTransportation -= payment.payment
        case .accommodation:
            settlementExpenses.totalAccommodation -= payment.payment
        case .tourism:
            settlementExpenses.totalTourism -= payment.payment
        case .food:
            settlementExpenses.totalFood -= payment.payment
        case .etc:
            settlementExpenses.totalEtc += payment.payment
        }
        
        resetExpense(payment: payment)
    }
    
    func resetExpense(payment: Payment) {
        var seperate: [Int] = [0, 0]
        for participant in payment.participants {
            if participant.seperateAmount != 0 {
                seperate[0] += 1
                seperate[1] += participant.seperateAmount
            }
        }
        
        for participant in payment.participants {
            let index = settlementExpenses.members.firstIndex { $0.memberData.id == participant.memberId }
            
            if participant.seperateAmount != 0 {
                settlementExpenses.members[index!].totalParticipationAmount += participant.seperateAmount
            }
            else {
                settlementExpenses.members[index!].totalParticipationAmount += ((payment.payment - seperate[1]) / (payment.participants.count - seperate[0]))
            }
            
            settlementExpenses.members[index!].totalParticipationAmount -= participant.advanceAmount
        }
    }
    
    func modifyExpenses(payment before : Payment, payment modified : Payment) {
        removeExpenses(payment: before)
        addExpenses(payment: modified)
    }
    
}
