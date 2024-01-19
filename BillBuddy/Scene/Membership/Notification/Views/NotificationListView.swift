//
//  NotificationView.swift
//  BillBuddy
//
//  Created by 윤지호 on 2023/09/22.
//

import SwiftUI
import Firebase
import FirebaseFirestore

struct NotificationListView: View {
    @Environment(\.dismiss) private var dismiss
//    @State private var isAllRead = false {
//        didSet {
//            updateAllReadStatus()
//        }
//    } 
    @State private var isPresentedAlert: Bool = false
    @EnvironmentObject private var notificationStore: NotificationService
    @EnvironmentObject private var tabViewStore: TabViewModel
    @EnvironmentObject private var userTravelStore: UserTravelStore

    private var db = Firestore.firestore()
    @State private var notifications: [Notification] = []
    @State private var selectedNotification: Notification?
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                ForEach(notificationStore.viewList) { notification in
                    NotificationCell(notification: notification, isRead: notification.isChecked) {
                        deleteNotification(notification)
                    } callBack: {
                        notificationStore.readNotifications(noti: notification)
                        switch notification.type {
                        case .chatting, .travel:
                            let travel = userTravelStore.getTravel(id: notification.contentId)
                            tabViewStore.pushView(type: notification.type, travel: travel)
                        case .invite:
                            selectedNotification = notification
                            isPresentedAlert = true
                        case .notice:
                            print("NotificationCell - notice")
                        }
                    }
                }
            }
        }
        .onAppear {
            fetchNotifications()
        }
        .navigationBarBackButtonHidden()
        .navigationBarTitleDisplayMode(.inline)
        .alert(isPresented: $isPresentedAlert) {
            Alert(title: Text("초대에 응하시겠습니까?"),
                  primaryButton: .destructive(Text("거절"), action: {
                getInvited(accept: false, selectedNotification: selectedNotification)
            }),
                  secondaryButton: .default(Text("들어가기"), action: {
                getInvited(accept: true, selectedNotification: selectedNotification)
            }))
        }
        .toolbar(content: {
            ToolbarItem(placement: .topBarLeading) {
                Button(action: {
                    dismiss()
                }, label: {
                    Image(.arrowBack)
                        .resizable()
                        .frame(width: 24, height: 24)
                })
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: {
                    notificationStore.readAll()
                }, label: {
                    Text("모두읽음")
                        .font(.body01)
                        .foregroundColor(notificationStore.notifications.isEmpty ? Color.gray : Color.myPrimary)
                })
                .disabled(notificationStore.notifications.isEmpty)
            }
            ToolbarItem(placement: .principal) {
                Text("알림")
                    .font(.title05)
            }
        })
    }
    
    private func fetchNotifications() {
        db.collection(StoreCollection.user.path).document(AuthService.shared.userUid).collection(StoreCollection.notification.path).getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error fetching notifications: \(error)")
            } else {
                var notifications: [Notification] = []
                for document in querySnapshot!.documents {
                    if let notification = try? document.data(as: Notification.self) {
                        notifications.append(notification)
                    }
                }
                // notifications.sorted(by: { $0.addDate > $1.addDate }
                self.notificationStore.notifications = notificationStore.setDuplicateNotifications(notifications)
            }
        }
    }
    
    private func deleteNotification(_ notification: Notification) {
        notificationStore.deleteNotification(notification)
    }
    
//    private func updateAllReadStatus() {
//        for index in notifications.indices {
//            notifications[index].isChecked = isAllRead
//        }
//    }
          
    private func getInvited(accept: Bool, selectedNotification: Notification?) {
        guard let selectedNotification else { return }
        switch accept {
        case true:
            InviteTravelService.shared.getInviteNoti(selectedNotification)
        case false:
            InviteTravelService.shared.denialInviteNoti(selectedNotification)
        }
    }
}

#Preview {
    NotificationListView()
        .environmentObject(NotificationService.shared)
        .environmentObject(TabViewModel.shared)
}
