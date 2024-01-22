//
//  MapStylePicker.swift
//  CurrencyHub
//
//  Created by Abylaykhan Myrzakhanov on 20.01.2024.
//

import SwiftUI
import MapKit

struct MapStylePicker: View {
    @Environment(\.dismiss) var dismiss
    
    @Binding var selectedMapStyle: MapStyle
    
    var body: some View {
        VStack {
            HStack {
                Text("Выбор карты")
                    .font(.title2)
                    .bold()
                Spacer()
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 16))
                        .foregroundStyle(.gray)
                        .padding(.all, 5)
                        .background(.gray.opacity(0.3))
                        .clipShape(.circle)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            HStack (spacing: 30) {
                Image("standard")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 150)
                    .overlay(alignment: .bottom) {
                        Text("Cтандартная")
                            .frame(width: 150)
                            .padding(.vertical, 5)
                            .background(.black)
                            .foregroundStyle(.white)
                    }
                    .clipShape(.rect(cornerRadius: 10))
                    .onTapGesture {
                        selectedMapStyle = .standard
                    }
                
                Image("hybrid")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 150)
                    .overlay(alignment: .bottom) {
                        Text("Гибридная")
                            .frame(width: 150)
                            .padding(.vertical, 5)
                            .background(.black)
                            .foregroundStyle(.white)
                    }
                    .clipShape(.rect(cornerRadius: 10))
                    .onTapGesture {
                        selectedMapStyle = .imagery
                    }
            }
        }
    }
}

#Preview {
    MapStylePicker(selectedMapStyle: .constant(.standard))
}
