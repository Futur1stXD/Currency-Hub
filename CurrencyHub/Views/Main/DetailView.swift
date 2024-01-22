//
//  DetailView.swift
//  CurrencyHub
//
//  Created by Abylaykhan Myrzakhanov on 22.01.2024.
//

import SwiftUI

struct DetailView: View {
    @Environment(\.dismiss) var dismiss
    
    @State private var selectedDetailType: DetailType = .CURRENCY
    
    @Binding var exchanger: Exchanger?
    @Binding var height: CGFloat
    
    var body: some View {
        NavigationStack {
            VStack {
                Picker("", selection: $selectedDetailType) {
                    ForEach(DetailType.allCases, id: \.self) { type in
                        Text(type.title)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, 20)
                .padding(.vertical, 5)
                
                if UIScreen.main.bounds.height < height {
                    ScrollView {
                        currencyTable()
                            .background(
                                GeometryReader { geometry in
                                    Color.clear
                                        .onAppear {
                                            height = geometry.size.height + 120
                                        }
                                        .onChange(of: exchanger?.id ?? "") {
                                            height = geometry.size.height + 120
                                        }
                                }
                            )
                    }
                } else {
                    currencyTable()
                        .background(
                            GeometryReader { geometry in
                                Color.clear
                                    .onAppear {
                                        height = geometry.size.height + 120
                                    }
                                    .onChange(of: exchanger?.id ?? "") {
                                        height = geometry.size.height + 120
                                    }
                            }
                        )
                }
            }
            .navigationTitle(exchanger?.title ?? "")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(content: {
                ToolbarItem {
                    Button(action: {dismiss()}, label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 12))
                            .foregroundStyle(.gray)
                            .padding(.all, 5)
                            .background(.gray.opacity(0.3))
                            .clipShape(.circle)
                    })
                }
            })
        }
    }
    
    @ViewBuilder
    private func currencyTable() -> some View {
        VStack {
            HStack {
                Text("Данные взяты с \(exchanger?.source.title ?? "")")
                    .font(.caption2)
                    .bold()
                Spacer()
                Text("Обновлено в \(minutesFromNow(to: exchanger?.actualTime ?? .now))")
                    .font(.caption2)
            }
            .padding(.horizontal)
            LazyVGrid(columns: [
                GridItem(.flexible(minimum: 100)),
                GridItem(.flexible(minimum: 100)),
                GridItem(.flexible(minimum: 100))
            ], alignment: .center, spacing: 10) {
                Text("Валюта")
                    .font(.headline)
                    .fontWeight(.bold)
                Text("Покупка")
                    .font(.headline)
                    .fontWeight(.bold)
                Text("Продажа")
                    .font(.headline)
                    .fontWeight(.bold)
                ForEach(exchanger?.currency ?? [], id:\.title) { currency in
                    VStack {
                        Text("\(currency.flag) \(currency.title)")
                            .font(.custom("Helvetica-Regular", size: 16))
                        Text("to KZT")
                            .font(.custom("Helvetica-Regular", size: 12))
                            .foregroundStyle(.gray.opacity(0.7))
                    }
                    Text(formatDouble(currency.buyPrice))
                    Text(formatDouble(currency.sellPrice))
                }
            }
            .padding()
            .background(.regularMaterial)
            .clipShape(.rect(cornerRadius: 20))
            .padding(.horizontal, 10)
            Button(action: {}, label: {
                Text("Обновить")
                    .padding(.all, 10)
                    .frame(width: 300)
                    .foregroundStyle(.white)
                    .background(.blue)
                    .clipShape(.rect(cornerRadius: 15))
                    .padding(.vertical, 5)
            })
        }
    }
    
    private func formatDouble(_ value: Double) -> String {
        if value == Double(Int(value)) {
            return String(Int(value))
        } else {
            return String(format: "%.2f", value)
        }
    }
    
    func minutesFromNow(to date: Date) -> Int {
        let now = Date()
        let calendar = Calendar.current

        // Убедитесь, что оба времени в UTC
        let utcCalendar = Calendar(identifier: .gregorian)
        let nowUTC = utcCalendar.date(bySettingHour: calendar.component(.hour, from: now),
                                      minute: calendar.component(.minute, from: now),
                                      second: calendar.component(.second, from: now),
                                      of: now)!
        let dateUTC = utcCalendar.date(bySettingHour: calendar.component(.hour, from: date),
                                       minute: calendar.component(.minute, from: date),
                                       second: calendar.component(.second, from: date),
                                       of: date)!

        let components = calendar.dateComponents([.minute], from: dateUTC, to: nowUTC)
        return components.minute ?? 0
    }
    
    private enum DetailType : CaseIterable {
        case CURRENCY, INFO
        
        var title: String {
            switch self {
            case .CURRENCY:
                return "Валюта"
            case .INFO:
                return "Инфо"
            }
        }
    }
}

#Preview {
    DetailView(exchanger: .constant(Exchanger(id: "", title: "", city: "", mainAddress: "", address: "", phones: [], actualTime: .now, coordinates: Coordinates(lat: 0, lng: 0), currency: [], workModes: Workmodes(mon: [], tue: [], wed: [], thu: [], fri: [], sat: [], sun: [], holyday: [], nonstop: false, closed: false, worknow: false), type: .EXCHANGER, source: .KURS)), height: .constant(0))
}
