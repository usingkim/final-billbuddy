//
//  PaymentManageViewModel.swift
//  BillBuddy
//
//  Created by 김유진 on 1/1/24.
//

import Foundation
import FirebaseFirestore

final class PaymentManageViewModel: ObservableObject {
    private var dbRef: CollectionReference
    private var payment: Payment
    private var id: String
    var updateContentDate: Double = 0
    
    init(travelCalculation: TravelCalculation) {
        self.travelCalculation = travelCalculation
        paymentDate = travelCalculation.startDate.toDate()
        self.dbRef = Firestore.firestore()
            .collection("TravelCalculation")
            .document(travelCalculation.id)
            .collection("Payment")
        id = travelCalculation.id
        payment = Payment(type: .etc, content: "", payment: 0, address: .init(address: "", latitude: 0, longitude: 0), participants: [], paymentDate: 0)
    }
    
    
    init(payment: Payment, travelCalculation: TravelCalculation) {
        selectedCategory = payment.type
        expandDetails = payment.content
        priceString = String(payment.payment)
        paymentDate = payment.paymentDate.toDate()
        searchAddress = payment.address.address
        self.payment = payment
        self.travelCalculation = travelCalculation
        dbRef = Firestore.firestore()
            .collection("TravelCalculation")
            .document(travelCalculation.id)
            .collection("Payment")
        id = travelCalculation.id
    }
    
    @Published var travelCalculation: TravelCalculation
    
    @Published var expandDetails: String = ""
    @Published var priceString: String = ""
    @Published var searchAddress: String = ""
    @Published var selectedCategory: Payment.PaymentType?
    @Published var paymentDate: Date = Date.now
    @Published var isShowingSelectTripSheet: Bool = false
    @Published var isShowingNoTravelAlert: Bool = false
    @Published var navigationTitleString: String = "지출 내역 추가"
    @Published var isShowingAlert: Bool = false
    @Published var participants: [Payment.Participant] = []
    @Published var isShowingMemberSheet: Bool = false
    
    var locationManager = LocationManager()
    
    func addPayment() {
        let newPayment =
        Payment(type: selectedCategory ?? .etc, content: expandDetails, payment: Int(priceString) ?? 0, address: Payment.Address(address: locationManager.selectedAddress, latitude: locationManager.selectedLatitude, longitude: locationManager.selectedLongitude), participants: participants, paymentDate: paymentDate.timeIntervalSince1970)
        
        Task {
//            if isPaymentSettled == true { return }
            try! dbRef.addDocument(from: newPayment.self)
            await saveUpdateDate()
//            await fetchAll()
//            settlementExpensesStore.setSettlementExpenses(payments: paymentStore.payments, members: self.travelCalculation.members)
        }
        
        PushNotificationManager.sendPushNotification(toTravel: travelCalculation, title: "\(travelCalculation.travelTitle)여행방", body: "지출이 추가 되었습니다.", senderToken: "senderToken")
//        notificationStore.sendNotification(members: travelCalculation.members, notification: UserNotification(type: .travel, content: "\(travelCalculation.travelTitle)여행방에서 확인하지 않은 지출", contentId: "\(URLSchemeBase.scheme.rawValue)://travel?travelId=\(travelCalculation.id)", addDate: Date(), isChecked: false))
    }
    
    func mainAddPayment() {
        let newPayment =
        Payment(type: selectedCategory ?? .etc, content: expandDetails, payment: Int(priceString) ?? 0, address: Payment.Address(address: locationManager.selectedAddress, latitude: locationManager.selectedLatitude, longitude: locationManager.selectedLongitude), participants: participants, paymentDate: paymentDate.timeIntervalSince1970)
        Task {
            try! dbRef.addDocument(from: newPayment.self)
        }
        
        PushNotificationManager.sendPushNotification(toTravel: travelCalculation, title: "\(travelCalculation.travelTitle)여행방", body: "지출이 추가 되었습니다.", senderToken: "senderToken")
//        notificationStore.sendNotification(members: travelCalculation.members, notification: UserNotification(type: .travel, content: "\(travelCalculation.travelTitle)여행방에서 확인하지 않은 지출", contentId: "\(URLSchemeBase.scheme.rawValue)://travel?travelId=\(travelCalculation.id)", addDate: Date(), isChecked: false))
    }
    
    func editPayment() {
        let newPayment = Payment(id: payment.id, type: selectedCategory ?? .etc, content: expandDetails, payment: Int(priceString) ?? 0, address: Payment.Address(address: locationManager.selectedAddress, latitude: locationManager.selectedLatitude, longitude: locationManager.selectedLongitude), participants: participants, paymentDate: paymentDate.timeIntervalSince1970)
        Task {
//            if isPaymentSettled == true { return }
            if let id = payment.id {
//                self.isFetchingList = true
                await saveUpdateDate()
                try? dbRef.document(id).setData(from: payment)

//                DispatchQueue.main.sync {
//                    if let index = payments.firstIndex(where: { $0.id == payment.id }) {
//                        payments[index] = payment
//                    }
//                    
//                    if let index = filteredPayments.firstIndex(where: { $0.id == payment.id }) {
//                        filteredPayments[index] = payment
//                    }
//                }
//                
//                self.isFetchingList = false
            }
//            settlementExpensesStore.setSettlementExpenses(payments: paymentStore.payments, members: self.travelCalculation.members)
        }
        
    }
    
    func saveUpdateDate() async {
//        if isPaymentSettled == true { return }
        do {
            let newUpdateDate = Date.now.timeIntervalSince1970
            try await Firestore.firestore()
                .collection(StoreCollection.travel.path)
                .document(self.id)
                .setData(["updateContentDate": newUpdateDate], merge: true)
            self.updateContentDate = newUpdateDate
        } catch {
            print("save date false")
        }
    }
    
}
