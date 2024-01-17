//
//  MapMainView.swift
//  BillBuddy
//
//  Created by 이승준 on 10/12/23.
//

import SwiftUI

struct MapMainView: View {
    @EnvironmentObject private var locationManager: LocationManager
    
    @ObservedObject var detailMainVM: DetailMainViewModel
    
    var body: some View {
        
        topMap
            .frame(height: 230)
        ScrollView {
            bottomList
        }
    }
    
    var topMap: some View {
        VStack {
            GeometryReader { geometry in
                VStack {
                    MapViewCoordinater(locationManager: locationManager)
                }
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
                .offset(CGSize(width: geometry.size.width - 65, height: geometry.size.height - 65))
            }
        }
        .onChange(of: detailMainVM.selectedDate, perform: { _ in
            detailMainVM.whenChangeSelectedDate()
            
            locationManager.setAnnotations(filteredPayments: detailMainVM.filteredPayments)
        })
        .onAppear {
            detailMainVM.whenOpenView()
            locationManager.setAnnotations(filteredPayments: detailMainVM.filteredPayments)
        }
    }
    
    var bottomList: some View {
        VStack {
            ForEach(Array(zip(0..<detailMainVM.filteredPayments.count, detailMainVM.filteredPayments)), id: \.0) { index, payment in
                HStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(Color.primary2)
                            .frame(height: 20)
                        Text("\(index + 1)")
                            .font(.body03)
                            .foregroundStyle(Color.white)
                    }
                    HStack {
                        VStack(alignment: .leading) {
                            Text(payment.content)
                                .font(.body01)
                            Label(payment.address.address, systemImage: "mappin.circle")
                                .font(.body04)
                                .foregroundStyle(Color(hex: "858899"))
                        }
                        Spacer()
                    }
                    .padding()
                    .frame(maxWidth: .infinity, minHeight: 70)
                    .background {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(hex: "F7F7FA"))
                    }
                }
            }
        }
        .padding()
    }
    
}

