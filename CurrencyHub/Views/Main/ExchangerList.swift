//
//  ExchangerList.swift
//  CurrencyHub
//
//  Created by Abylaykhan Myrzakhanov on 21.01.2024.
//

import SwiftUI

struct ExchangerList: View {
    @EnvironmentObject var exchangerViewModel: ExchangerViewModel
    @EnvironmentObject var locationViewModel: LocationViewModel
    
    @Binding var openSearchList: Bool
    @Binding var selectedExchanger: String?
    
    @State private var searchText: String = ""
    
    var sortedList: [Exchanger] {
        let filteredList = exchangerViewModel.exchangers.filter { exchanger in
            return searchText.isEmpty || exchanger.title.localizedCaseInsensitiveContains(searchText)
        }
        
        return filteredList.sorted { exchanger1, exchanger2 in
            if let distance1 = Double(locationViewModel.calculateDistance(latitude: exchanger1.coordinates.lat, longitude: exchanger1.coordinates.lng)),
               let distance2 = Double(locationViewModel.calculateDistance(latitude: exchanger2.coordinates.lat, longitude: exchanger2.coordinates.lng)) {
                return distance1 < distance2
            }
            return false
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                TextField("Поиск", text: $searchText)
                    .padding(.leading, 30)
                    .padding(.horizontal)
                    .padding(.vertical, 10)
                    .background(
                        ZStack {
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .fill(.ultraThinMaterial)

                            HStack {
                                Image(systemName: "magnifyingglass")
                                    .foregroundColor(.secondary)
                                    .padding(.leading, 10)
                                Spacer()
                            }
                        }
                    )
                    .padding(.horizontal)
                    .foregroundStyle(.primary)
                    .cornerRadius(10)
                    .shadow(radius: 2)
                if exchangerViewModel.exchangers.count != 0 {
                    List {
                        ForEach(sortedList, id:\.id) { exchanger in
                            ExchangerRow(title: exchanger.title, address: exchanger.mainAddress, lat: exchanger.coordinates.lat, lng: exchanger.coordinates.lng, isOpen: exchanger.workModes.closed)
                                .onTapGesture {
                                    withAnimation {
                                        openSearchList = false
                                        selectedExchanger = exchanger.id
                                    }
                                }
                        }
                    }
                    .listStyle(.plain)
                } else {
                    ProgressView()
                    Spacer()
                }
            }
            .toolbar {
                ToolbarItem {
                    Button(action: {openSearchList.toggle()}, label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 12))
                            .foregroundStyle(.gray)
                            .padding(.all, 5)
                            .background(.gray.opacity(0.3))
                            .clipShape(.circle)
                    })
                }
            }
        }
    }
    private struct ExchangerRow: View {
        @EnvironmentObject var locationViewModel: LocationViewModel
        
        let title: String
        let address: String
        let lat: Double
        let lng: Double
        let isOpen: Bool
        
        var body: some View {
            HStack {
                Text("💸")
                    .frame(width: 40, height: 40)
                    .background(!isOpen ? .green : .red)
                    .clipShape(.rect(cornerRadius: 10))
                
                VStack (alignment: .leading) {
                    Text(title)
                        .font(.title3)
                    Text(address)
                        .foregroundStyle(.gray)
                        .font(.footnote)
                }
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    Text("открыт")
                        .foregroundStyle(!isOpen ? .green : .red)
                        .font(.subheadline)
                    HStack {
                        Image(systemName: "figure.walk")
                            .foregroundStyle(.gray)
                            .font(.system(size: 14))
                        Text("~\(locationViewModel.calculateDistance(latitude: lat, longitude: lng)) км")
                            .foregroundStyle(.gray)
                            .font(.footnote)
                    }
                }
            }
        }
    }
}

#Preview {
    ExchangerList(openSearchList: .constant(false), selectedExchanger: .constant(""))
        .environmentObject(LocationViewModel())
        .environmentObject(ExchangerViewModel())
}
