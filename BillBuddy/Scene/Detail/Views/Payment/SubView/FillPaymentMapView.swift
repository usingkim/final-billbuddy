//
//  AddPaymentMapView.swift
//  BillBuddy
//
//  Created by 이승준 on 10/11/23.
//

import SwiftUI

struct FillPaymentMapView: View {
    @ObservedObject var locationManager: LocationManager
    @ObservedObject var paymentManageVM: PaymentManageViewModel

    @FocusState private var isKeyboardUp: Bool
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 16) {
                HStack {
                    Text("위치")
                        .font(.body02)
                    Spacer()
                    if paymentManageVM.isShowingAddress {
                        Text("\(locationManager.selectedAddress)")
                            .font(.body04)
                    }
                }
                if paymentManageVM.isShowingMapView == false {
                    HStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(uiColor: .systemGray6))
                            .frame(width: geometry.size.width * 4.6/5, height: 40)
                            .overlay(alignment: .leading) {
                                HStack {
                                    TextField("주소 입력", text: $paymentManageVM.searchAddress)
                                        .font(.body04)
                                        .padding()
                                    Button(action: {
                                        locationManager.searchAddress(searchAddress: paymentManageVM.searchAddress)
                                        paymentManageVM.isShowingAddress = true
                                        paymentManageVM.isShowingMapView = true
                                        
                                    }, label: {
                                        Image("my_location")
                                            .resizable()
                                            .frame(width: 24, height: 24)
                                            .foregroundStyle(Color.primary2)
                                    })
                                    .padding()
                                    .focused($isKeyboardUp)
                                }
                            }
                    }
                }
                if paymentManageVM.isShowingMapView == true {
                    MapViewCoordinater(locationManager: locationManager)
                        .frame(width: 329, height: 170)
                        .cornerRadius(12)
                }
                Spacer()
            }
            .padding()
            
            if paymentManageVM.isShowingMapView == true {
                Button {
                    locationManager.moveFocusOnUserLocation()
                } label: {
                    Circle()
                        .fill(Color.white)
                        .frame(width: 40, height: 40)
                        .shadow(radius: 2, y: 1)
                        .overlay {
                            Image("my_location")
                                .resizable()
                                .frame(width: 24, height: 24)
                        }
                }
                .onTapGesture {
                    isKeyboardUp = false
                }
                .offset(CGSize(width: geometry.size.width - 70, height: geometry.size.height / 3))
                
                Image(systemName: "mappin")
                    .resizable()
                    .position(CGPoint(x: geometry.size.width / 2, y: locationManager.isChaging ? (geometry.size.height / 2 - 5) : (geometry.size.height / 2)))
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 24, alignment: .center)
                    .foregroundStyle(Color.myPrimary)
            }
        }
        .frame(height: paymentManageVM.isShowingMapView ? 248 : 120)
    }
}
