//
//  DetailView.swift
//  CurrencyHub
//
//  Created by Abylaykhan Myrzakhanov on 22.01.2024.
//

import SwiftUI

struct DetailView: View {
    @EnvironmentObject var locationViewModel: LocationViewModel
    @EnvironmentObject var exchangerViewModel: ExchangerViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var selectedDetailType: DetailType = .CURRENCY
    
    @Binding var exchanger: Exchanger?
    @Binding var height: CGFloat
    
    @State private var openTime: Bool = false
    
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
                
                if selectedDetailType == .CURRENCY {
                    if UIScreen.main.bounds.height <= height {
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
                } else {
                    info()
                        .background(
                            GeometryReader { geometry in
                                Color.clear
                                    .onAppear {
                                        withAnimation {
                                            height = geometry.size.height + 120
                                        }
                                    }
                                    .onChange(of: exchanger?.id ?? "") {
                                        withAnimation {
                                            height = geometry.size.height + 120
                                        }
                                    }
                                    .onChange(of: openTime) {
                                        withAnimation {
                                            height = geometry.size.height + 120
                                        }
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
                Text("\(NSLocalizedString("main_data_tacked", comment: "")) \(exchanger?.source.title ?? "")")
                    .font(.caption2)
                    .bold()
                Spacer()
                VStack {
                    Text("\(NSLocalizedString("main_updated", comment: "")) \(calculateTimeDiff(from: exchanger?.actualTime ?? .now))")
                        .font(.caption2)
                    Text("\(formatDate(date: exchanger?.actualTime ?? .now))")
                        .font(.system(size: 10))
                        .foregroundStyle(.gray)
                }
            }
            .padding(.horizontal)
            LazyVGrid(columns: [
                GridItem(.flexible(minimum: 100)),
                GridItem(.flexible(minimum: 100)),
                GridItem(.flexible(minimum: 100))
            ], alignment: .center, spacing: 10) {
                Text("main_sort_currency")
                    .font(.headline)
                    .fontWeight(.bold)
                Text("main_buy")
                    .font(.headline)
                    .fontWeight(.bold)
                Text("main_sell")
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
        }
    }
    
    @ViewBuilder
    private func info() -> some View {
        VStack {
            VStack(alignment: .leading) {
                HStack {
                    VStack(alignment: .leading, spacing: 5) {
                        Text("main_info_address")
                            .font(.system(size: 18))
                            .bold()
                        Text(exchanger?.mainAddress ?? "")
                            .font(.system(size: 16))
                            .lineLimit(20)
                        
                        Text(exchanger?.city ?? "")
                            .font(.system(size: 16))
                    }
                    Spacer()
                    Text("~\(locationViewModel.calculateDistance(latitude: exchanger?.coordinates.lat ?? 0, longitude: exchanger?.coordinates.lng ?? 0)) \(NSLocalizedString("kilometers", comment: ""))")
                }
                if exchanger?.mainAddress ?? "" != exchanger?.address ?? "" {
                    Divider()
                    Text(exchanger?.address ?? "")
                        .lineLimit(10)
                        .foregroundStyle(.gray)
                }
            }
            .padding(.all, 10)
            .background(.gray.opacity(0.15))
            .clipShape(.rect(cornerRadius: 15))
            .padding(.horizontal)
            
            if !openTime {
                HStack {
                    VStack(alignment: .leading, spacing: 5) {
                        Text("main_info_working_hours")
                            .font(.system(size: 18))
                            .bold()
                        Text(workingHoursForToday())
                    }
                    Spacer()
                    Image(systemName: "chevron.right")
                }
                .padding(.all, 10)
                .background(.gray.opacity(0.15))
                .clipShape(.rect(cornerRadius: 15))
                .padding(.horizontal)
                .transition(.move(edge: .leading))
                .zIndex(1)
                .onTapGesture {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        openTime.toggle()
                    }
                }
            } else {
                showWorkModes()
                    .transition(.move(edge: .trailing))
                    .zIndex(1)
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            openTime.toggle()
                        }
                    }
            }
            
            VStack (alignment: .leading, spacing: 5) {
                Text("about_app_contacts")
                    .font(.system(size: 18))
                    .bold()
                ForEach(exchanger?.phones ?? [], id:\.self) { phone in
                    HStack {
                        Text(phone)
                        Spacer()
                        Image(systemName: "phone")
                            .font(.system(size: 16))
                    }
                    .font(.system(size: 16))
                    .foregroundStyle(.blue)
                    .onTapGesture {
                        if let appUrl = URL(string: "tel://+\(phone.filter {$0.isNumber})") {
                            UIApplication.shared.open(appUrl)
                        }
                    }
                }
            }
            .padding(.all, 10)
            .background(.gray.opacity(0.15))
            .clipShape(.rect(cornerRadius: 15))
            .padding(.horizontal)
            
            Button {
                let url = "https://2gis.kz/\(locationViewModel.city ?? "")/geo/\(exchanger?.coordinates.lng ?? 0)%2C\(exchanger?.coordinates.lat ?? 0)"
                guard let appUrl = URL(string: url) else { return }
                if UIApplication.shared.canOpenURL(appUrl) {
                    UIApplication.shared.open(appUrl, options: [:], completionHandler: nil)
                }
            } label: {
                Text("\(NSLocalizedString("main_info_open_in", comment: "")) 2GIS")
            }
            .padding(.all, 10)
            .frame(width: 300)
            .foregroundStyle(.white)
            .background(.blue)
            .clipShape(.rect(cornerRadius: 15))
            .padding(.vertical, 5)
        }
    }
    
    private func formatDouble(_ value: Double) -> String {
        if value == Double(Int(value)) {
            return String(Int(value))
        } else {
            return String(format: "%.2f", value)
        }
    }
    
    private func formatDate(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .medium
        return formatter.string(from: date)
    }
    
    func calculateTimeDiff(from date: Date) -> String {
        let now = Date()
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: date, to: now)
        
        if let hours = components.hour, hours > 0 {
            if hours == 1 {
                return "\(hours) \(NSLocalizedString("main_hour_ago", comment: ""))"
            }
            return "\(hours) \(NSLocalizedString("main_hours_ago", comment: ""))"
        } else if let minutes = components.minute {
            return "\(minutes) \(NSLocalizedString("main_minute_ago", comment: ""))"
        } else {
            return "\(NSLocalizedString("main_just_now", comment: ""))"
        }
    }
    
    @ViewBuilder
    private func showWorkModes() -> some View {
        VStack(alignment: .leading) {
            HStack {
                VStack(alignment: .leading, spacing: 5) {
                    Text("main_info_working_hours")
                        .font(.system(size: 18))
                        .bold()
                    if let workMode = exchanger?.workModes {
                        Text("\(NSLocalizedString("monday", comment: "")): \(workMode.mon.first ?? "") - \(workMode.mon[1])")
                        Text("\(NSLocalizedString("tuesday", comment: "")): \(workMode.tue.first ?? "") - \(workMode.tue[1])")
                        Text("\(NSLocalizedString("wednesday", comment: "")): \(workMode.wed.first ?? "") - \(workMode.wed[1])")
                        Text("\(NSLocalizedString("thursday", comment: "")): \(workMode.thu.first ?? "") - \(workMode.thu[1])")
                        Text("\(NSLocalizedString("friday", comment: "")): \(workMode.fri.first ?? "") - \(workMode.fri[1])")
                        Text("\(NSLocalizedString("saturday", comment: "")): \(workMode.sat.first ?? "") - \(workMode.sat[1])")
                        Text("\(NSLocalizedString("sunday", comment: "")): \(workMode.sun.first ?? "") - \(workMode.sun[1])")
                    }
                }
                Spacer()
                Image(systemName: "chevron.down")
            }
        }
        .padding(.all, 10)
        .background(.gray.opacity(0.15))
        .clipShape(.rect(cornerRadius: 15))
        .padding(.horizontal)
    }
    
    private func workingHoursForToday() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE"
        let currentDayOfWeek = dateFormatter.string(from: Date()).lowercased()
        switch currentDayOfWeek {
        case "monday":
            return "\(NSLocalizedString("monday", comment: "")): \(exchanger?.workModes.mon.first ?? "") - \(exchanger?.workModes.mon[1] ?? "")"
        case "tuesday":
            return "\(NSLocalizedString("tuesday", comment: "")): \(exchanger?.workModes.tue.first ?? "") - \(exchanger?.workModes.tue[1] ?? "")"
        case "wednesday":
            return "\(NSLocalizedString("wednesday", comment: "")): \(exchanger?.workModes.wed.first ?? "") - \(exchanger?.workModes.wed[1] ?? "")"
        case "thursday":
            return "\(NSLocalizedString("thursday", comment: "")): \(exchanger?.workModes.thu.first ?? "") - \(exchanger?.workModes.thu[1] ?? "")"
        case "friday":
            return "\(NSLocalizedString("friday", comment: "")): \(exchanger?.workModes.fri.first ?? "") - \(exchanger?.workModes.fri[1] ?? "")"
        case "saturday":
            return "\(NSLocalizedString("saturday", comment: "")): \(exchanger?.workModes.sat.first ?? "") - \(exchanger?.workModes.sat[1] ?? "")"
        case "Sunday":
            return "\(NSLocalizedString("sunday", comment: "")): \(exchanger?.workModes.sun.first ?? "") - \(exchanger?.workModes.sun[1] ?? "")"
        default:
            return NSLocalizedString("main_error", comment: "")
        }
    }
    
    private enum DetailType : CaseIterable {
        case CURRENCY, INFO
        
        var title: String {
            switch self {
            case .CURRENCY:
                return NSLocalizedString("main_sort_currency", comment: "")
            case .INFO:
                return NSLocalizedString("main_info", comment: "")
            }
        }
    }
}

#Preview {
    DetailView(exchanger: .constant(Exchanger(id: "", title: "", city: "", mainAddress: "", address: "", phones: [], actualTime: .now, coordinates: Coordinates(lat: 0, lng: 0), currency: [], workModes: Workmodes(mon: [], tue: [], wed: [], thu: [], fri: [], sat: [], sun: [], holyday: [], nonstop: false, closed: false, worknow: false), type: .EXCHANGER, source: .KURS)), height: .constant(0))
        .environmentObject(LocationViewModel())
        .environmentObject(ExchangerViewModel())
}
