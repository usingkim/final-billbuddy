//
//  SelectCategorySheet.swift
//  BillBuddy
//
//  Created by 김유진 on 10/12/23.
//

import SwiftUI

struct CategorySelectView: View {
    
    
    @Environment(\.dismiss) private var dismiss
    
    enum Mode {
        case category // 전체 x
        case sheet    // 전체 o
    }
    
    
    @State var mode: Mode
    
    @Binding var selectedCategory: Payment.PaymentType?
    
    var body: some View {
        HStack(spacing: 36) {
            if mode == .sheet {
                Button(action: {
                    selectedCategory = nil
                }, label: {
                    if selectedCategory == nil {
                        Text("전체")
                            .font(.caption02)
                            .foregroundStyle(Color.myPrimary)
                    }
                    else {
                        Text("전체")
                            .font(.caption02)
                            .foregroundStyle(Color.black)
                    }
                })
                .buttonStyle(.plain)
            }
                
            ForEach(Payment.PaymentType.allCases, id:\.self) { category in
                Button(action: {
                        selectedCategory = category
                }, label: {
                    VStack {
                        if let selected = selectedCategory {
                            Image(category.getImageString(type: .thin))
                                .renderingMode(.template)
                                .resizable()
                                .frame(width: 24, height: 24)
                                .foregroundStyle(selected == category ? Color.myPrimary : Color.gray600)
                            Text(category.string)
                                .font(.caption02)
                                .foregroundStyle(selected == category ? Color.myPrimary : Color.gray600)
                                
                        }
                        else {
                            Image(category.getImageString(type: .thin))
                                .renderingMode(.template)
                                .resizable()
                                .frame(width: 24, height: 24)
                                .foregroundStyle(Color.gray600)
                            Text(category.string)
                                .font(.caption02)
                                .foregroundStyle(Color.gray600)
                            
                        }
                        
                        
                    }
                })
                .buttonStyle(.plain)
            }
        }
        .onChange(of: selectedCategory, perform: { _ in
            if mode == .sheet {
                dismiss()
            }
        })
    }
}
