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
    
    @Binding var searchText: String
    @Binding var openSortSettings: Bool
    @Binding var selectedSettings: SortSettings
    @Binding var selectedCurrency: Currency
    @Binding var selectedBuyOrSell: SortSetBuyOrSell
    
    @Binding var sortedList: [Exchanger]
    
    var body: some View {
        NavigationStack {
            VStack {
                HStack {
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
                        .padding(.leading, 10)
                        .foregroundStyle(.primary)
                        .cornerRadius(10)
                        .shadow(radius: 2)
                    Button {
                        openSortSettings.toggle()
                    } label: {
                        Image(systemName: "arrow.up.arrow.down.circle")
                            .font(.system(size: 26))
                    }
                    .foregroundStyle(.blue)
                    .padding(.all, 5)
                    .background(
                        ZStack {
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .fill(.ultraThinMaterial)
                        }
                    )
                    .shadow(radius: 1)
                }
                .padding(.horizontal, 10)
                if exchangerViewModel.exchangers.count != 0 {
                    List (sortedList, id:\.id) { exchanger in
                        ExchangerRow(title: exchanger.title, address: exchanger.mainAddress, lat: exchanger.coordinates.lat, lng: exchanger.coordinates.lng, isOpen: exchanger.workModes.worknow)
                            .onTapGesture {
                                withAnimation {
                                    openSearchList = false
                                    selectedExchanger = exchanger.id
                                }
                            }
                    }
                    .listStyle(.plain)
                    .sheet(isPresented: $openSortSettings, content: {
                        SortSettingsSheet(isOpen: $openSortSettings, selection: $selectedSettings, selectionCurrency: $selectedCurrency, selectedBuyOrSell: $selectedBuyOrSell)
                            .presentationDetents([.height(250)])
                            .presentationCornerRadius(20)
                    })
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
                    .background(isOpen ? .green : .red)
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
                    Text(isOpen ? "открыт" : "закрыт")
                        .foregroundStyle(isOpen ? .green : .red)
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
    
    private struct SortSettingsSheet: View {
        @Environment(\.dismiss) var dismiss
        
        @Binding var isOpen: Bool
        @Binding var selection: SortSettings
        @Binding var selectionCurrency: Currency
        @Binding var selectedBuyOrSell: SortSetBuyOrSell
        
        var body: some View {
            NavigationStack {
                List(SortSettings.allCases, id:\.title) { settings in
                    VStack {
                        HStack {
                            Text(settings.title)
                            Spacer()
                            Image(systemName: selection.title == settings.title ? "checkmark.circle.fill" : "circle")
                                .foregroundStyle(selection.title == settings.title ? .blue : .primary)
                        }
                        .onTapGesture {
                            selection = settings
                        }
                        if selection == .CURRENCY && settings == .CURRENCY {
                            HStack {
                                Picker("", selection: $selectionCurrency) {
                                    ForEach(Currency.allCases, id:\.self) { currency in
                                        Text("\(currency.flag) \(currency.rawValue)")
                                    }
                                }
                                .frame(width: 100)
                                Spacer()
                                ForEach(SortSetBuyOrSell.allCases, id:\.self) { buyOrSell in
                                    HStack(spacing: 10) {
                                        Text("\(buyOrSell.title)")
                                            .font(.caption2)
                                        Image(systemName: selectedBuyOrSell.title == buyOrSell.title ? "checkmark.circle.fill" : "circle")
                                            .foregroundStyle(selectedBuyOrSell.title == buyOrSell.title ? .blue : .primary)
                                    }
                                    .onTapGesture {
                                        selectedBuyOrSell = buyOrSell
                                    }
                                }
                            }
                        }
                    }
                }
                .listStyle(.plain)
                .navigationTitle("Сортировка")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            dismiss()
                        } label: {
                            Image(systemName: "xmark")
                                .font(.system(size: 12))
                                .foregroundStyle(.gray)
                                .padding(.all, 4)
                                .background(.gray.opacity(0.3))
                                .clipShape(.circle)
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    ExchangerList(openSearchList: .constant(false), selectedExchanger: .constant(""), searchText: .constant(""), openSortSettings: .constant(false), selectedSettings: .constant(.ALL), selectedCurrency: .constant(.USD), selectedBuyOrSell: .constant(.BUY), sortedList: .constant([]))
        .environmentObject(LocationViewModel())
        .environmentObject(ExchangerViewModel())
}
