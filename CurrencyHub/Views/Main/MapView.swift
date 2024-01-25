//
//  MapView.swift
//  CurrencyHub
//
//  Created by Abylaykhan Myrzakhanov on 20.01.2024.
//

import SwiftUI
import MapKit

struct MapView: View {
    @EnvironmentObject var exchangerViewModel: ExchangerViewModel
    @EnvironmentObject var locationViewModel: LocationViewModel
    
    @State private var cameraPosition: MapCameraPosition = .automatic
    @State private var visibleRegion: MKCoordinateRegion = .init()
    
    @State private var showMapStyle: Bool = false
    @State private var selectedMapStyle: MapStyle = .standard
    
    @State private var openSearchList: Bool = false
    @State private var openCityList: Bool = false
    @State private var selectedCity: City = .ASTANA
    
    @State private var searchText: String = ""
    @State private var selectedExchangerId: String?
    @State private var selectedExchanger: Exchanger?
    @State private var openDetailSheet: Bool = false
    @State private var heightDetailView: CGFloat = 0
    
    @State private var openSortSettings: Bool = false
    @State private var selectedSettings: SortSettings = .ALL
    @State private var selectedCurrency: Currency = .USD
    @State private var selectedBuyOrSell: SortSetBuyOrSell = .BUY
    
    var sortedList: [Exchanger] {
        let filteredList = exchangerViewModel.exchangers.filter { exchanger in
            return searchText.isEmpty || exchanger.title.localizedCaseInsensitiveContains(searchText)
        }
        
        var filteredAndSorted: [Exchanger] = []
        
        switch selectedSettings {
        case .ALL:
            filteredAndSorted = filteredList.sorted { exchanger1, exchanger2 in
                if let distance1 = Double(locationViewModel.calculateDistance(latitude: exchanger1.coordinates.lat, longitude: exchanger1.coordinates.lng)),
                   let distance2 = Double(locationViewModel.calculateDistance(latitude: exchanger2.coordinates.lat, longitude: exchanger2.coordinates.lng)) {
                    return distance1 < distance2
                }
                return false
            }
            
        case .CURRENCY:
            let filterByCurrency = filteredList.filter { exchanger in
                exchanger.currency.contains { currency in
                    currency.title == selectedCurrency.rawValue
                }
            }
            filteredAndSorted = filterByCurrency.sorted { exchanger1, exchanger2 in
                switch selectedBuyOrSell {
                case .BUY:
                    let buyPrice1 = exchanger1.currency.first { $0.title == selectedCurrency.rawValue }?.buyPrice ?? 0
                    let buyPrice2 = exchanger2.currency.first { $0.title == selectedCurrency.rawValue }?.buyPrice ?? 0
                    return buyPrice1 > buyPrice2
                    
                case .SELL:
                    let sellPrice1 = exchanger1.currency.first { $0.title == selectedCurrency.rawValue }?.sellPrice ?? 0
                    let sellPrice2 = exchanger2.currency.first { $0.title == selectedCurrency.rawValue }?.sellPrice ?? 0
                    return sellPrice1 < sellPrice2
                }
            }
            
        case .LAST_UPDATE:
            filteredAndSorted = filteredList.sorted { exchanger1, exchanger2 in
                return exchanger1.actualTime > exchanger2.actualTime
            }
        }
        return filteredAndSorted
    }
    
    var body: some View {
        ZStack {
            Map(position: $cameraPosition, selection: $selectedExchangerId) {
                UserAnnotation()
                ForEach(sortedList, id: \.id) { exchanger in
                    Marker(exchanger.title, systemImage: "storefront", coordinate: exchanger.coordinates.coordinates)
                        .annotationTitles(.automatic)
                        .annotationSubtitles(.automatic)
                        .tint(.blue)
                        .tag(exchanger.id)
                }
            }
            .mapStyle(selectedMapStyle)
            .mapControlVisibility(.hidden)
            .onMapCameraChange { context in
                visibleRegion = context.region
            }
            .onChange(of: selectedExchangerId) { oldValue, newValue in
                if let findExchanger = exchangerViewModel.exchangers.first(where: {$0.id == selectedExchangerId}) {
                    let span = MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
                    selectedExchanger = findExchanger
                    withAnimation {
                        cameraPosition = .region(MKCoordinateRegion(center: findExchanger.coordinates.coordinates, span: span))
                        
                        if newValue == nil {
                            openDetailSheet = false
                        } else {
                            openDetailSheet = true
                        }
                    }
                }
            }
        }
        .safeAreaInset(edge: .trailing) {
            VStack(spacing: 15) {
                MapButton(systemName: "map.fill") {
                    withAnimation {
                        self.showMapStyle.toggle()
                    }
                }
                MapButton(systemName: "mappin.and.ellipse.circle.fill") {
                    openCityList.toggle()
                }
                Spacer()
                MapButton(systemName: "plus.circle", action: zoomIn)
                MapButton(systemName: "minus.circle", action: zoomOut)
                MapButton(systemName: "location.viewfinder") {
                    cameraPosition = .region(locationViewModel.region)
                    
                    if selectedCity.title != locationViewModel.city {
                        Task {
                            await exchangerViewModel.fetchKursKz(city: locationViewModel.city?.localizedLowercase ?? "")
                        }
                    }
                }
                Spacer()
            }
            .padding(.trailing, 10)
        }
        .overlay(alignment: .bottomLeading) {
            VStack {
                Button {
                    openSearchList.toggle()
                } label: {
                    Image(systemName: "magnifyingglass.circle.fill")
                        .font(.system(size: 32))
                        .foregroundStyle(.white)
                }
                .padding(.all, 5)
                .background(.blue)
                .clipShape(.circle)
                
            }
            .padding(.leading, 20)
            .padding(.bottom, 30)
        }
        .overlay(alignment: .center) {
            if exchangerViewModel.error {
                VStack (alignment: .center) {
                    Text("\(NSLocalizedString("main_error", comment: "")) 🥲")
                    Text("\(exchangerViewModel.errorMessage)")
                    Button(action: {
                        Task {
                            await exchangerViewModel.fetchKursKz(city: locationViewModel.city?.lowercased() ?? "")
                            exchangerViewModel.error.toggle()
                        }
                    }, label: {
                        Text("main_update")
                            .padding(.all, 10)
                            .frame(width: 100)
                            .foregroundStyle(.white)
                            .background(.blue)
                            .clipShape(.rect(cornerRadius: 15))
                            .padding(.vertical, 5)
                    })
                }
                .padding(.all, 20)
                .background(.ultraThinMaterial)
                .clipShape(.rect(cornerRadius: 15))
                .padding(.horizontal, 20)
            }
        }
        .sheet(isPresented: $showMapStyle, content: {
            MapStylePicker(selectedMapStyle: $selectedMapStyle)
                .presentationDetents([.height(230)])
        })
        .sheet(isPresented: $openCityList, content: {
            CityList(cameraPosition: $cameraPosition, selectedCity: $selectedCity, openCityList: $openCityList)
                .presentationDetents([.medium])
                .presentationCornerRadius(20)
        })
        .sheet(isPresented: $openSearchList, content: {
            ExchangerList(openSearchList: $openSearchList, selectedExchanger: $selectedExchangerId, searchText: $searchText, openSortSettings: $openSortSettings, selectedSettings: $selectedSettings, selectedCurrency: $selectedCurrency, selectedBuyOrSell: $selectedBuyOrSell, sortedList: .constant(sortedList))
                .presentationDetents([.height(300), .large])
                .presentationCornerRadius(20)
                .presentationBackgroundInteraction(.enabled(upThrough: .height(300)))
        })
        .sheet(isPresented: $openDetailSheet, content: {
            DetailView(exchanger: $selectedExchanger, height: $heightDetailView)
                .presentationDetents(heightDetailView > 700 ? [.height(350), .large] : [.height(heightDetailView)])
                .presentationCornerRadius(20)
                .presentationBackgroundInteraction(.enabled(upThrough: .height(heightDetailView > 700 ? 350 : heightDetailView)))
        })
        .onChange(of: locationViewModel.city) {
            if let cityString = locationViewModel.city {
                selectedCity = City.allCases.first { $0.title == cityString } ?? City.ASTANA
            }
            if exchangerViewModel.exchangers.count == 0 {
                Task {
                    await exchangerViewModel.fetchKursKz(city: locationViewModel.city?.lowercased() ?? "")
                }
            }
        }
        .onAppear {
            cameraPosition = .region(locationViewModel.region)
        }
    }
    
    private func zoomIn() {
        visibleRegion.span.longitudeDelta /= 2.0
        visibleRegion.span.latitudeDelta /= 2.0
        
        cameraPosition = .region(visibleRegion)
    }
    
    private func zoomOut() {
        visibleRegion.span.longitudeDelta *= 2.0
        visibleRegion.span.latitudeDelta *= 2.0
        
        cameraPosition = .region(visibleRegion)
    }
    
    private struct MapButton: View {
        let systemName: String
        let action: () -> Void
        
        var body: some View {
            Button(action: {
                withAnimation {
                    action()
                }
            }) {
                Image(systemName: systemName)
                    .font(.system(size: 20))
                    .foregroundColor(.white)
                    .padding(10)
                    .background(Circle()
                        .fill(.blue))
            }
        }
    }
    
    private enum City: CaseIterable {
        case ALMATY, ASTANA, AKSU, AKTAU, AKTOBE, KASKELEN,
             KOSTANAI, PAVLODAR, RIDDER, SEMEI, TALDYKORGAN, URALSK, SHYMKENT
        
        var title: String {
            switch self {
            case .ALMATY:
                return NSLocalizedString("city_almaty", comment: "")
            case .ASTANA:
                return NSLocalizedString("city_astana", comment: "")
            case .AKSU:
                return NSLocalizedString("city_aksu", comment: "")
            case .AKTAU:
                return NSLocalizedString("city_aktau", comment: "")
            case .AKTOBE:
                return NSLocalizedString("city_aktobe", comment: "")
            case .KASKELEN:
                return NSLocalizedString("city_kaskelen", comment: "")
            case .KOSTANAI:
                return NSLocalizedString("city_kostanai", comment: "")
            case .PAVLODAR:
                return NSLocalizedString("city_pavlodar", comment: "")
            case .RIDDER:
                return NSLocalizedString("city_ridder", comment: "")
            case .SEMEI:
                return NSLocalizedString("city_semei", comment: "")
            case .TALDYKORGAN:
                return NSLocalizedString("city_taldykorgan", comment: "")
            case .URALSK:
                return NSLocalizedString("city_uralsk", comment: "")
            case .SHYMKENT:
                return NSLocalizedString("city_shymkent", comment: "")
            }
        }
        
        var cityForFetch: String {
            switch self {
            case .ALMATY:
                return "almaty"
            case .ASTANA:
                return "astana"
            case .AKSU:
                return "aksu (pavlodar region)"
            case .AKTAU:
                return "aktau"
            case .AKTOBE:
                return "aktobe"
            case .KASKELEN:
                return "kaskelen"
            case .KOSTANAI:
                return "kostanai"
            case .PAVLODAR:
                return "pavlodar"
            case .RIDDER:
                return "ridder"
            case .SEMEI:
                return "semei"
            case .TALDYKORGAN:
                return "taldykorgan"
            case .URALSK:
                return "uralsk"
            case .SHYMKENT:
                return "shymkent"
            }
        }
        
        var regionCoordinate: MKCoordinateRegion {
            switch self {
            case .ALMATY:
                return MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 43.24278, longitude: 76.894131), latitudinalMeters: 6000, longitudinalMeters: 6000)
            case .ASTANA:
                return MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 51.129546, longitude: 71.443115), latitudinalMeters: 6000, longitudinalMeters: 6000)
            case .AKSU:
                return MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 52.036244, longitude: 76.933104), latitudinalMeters: 6000, longitudinalMeters: 6000)
            case .AKTAU:
                return MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 43.635586, longitude: 51.168276), latitudinalMeters: 6000, longitudinalMeters: 6000)
            case .AKTOBE:
                return MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 50.300223, longitude: 57.154108), latitudinalMeters: 6000, longitudinalMeters: 6000)
            case .KASKELEN:
                return MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 43.19982, longitude: 76.621829), latitudinalMeters: 6000, longitudinalMeters: 6000)
            case .KOSTANAI:
                return MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 53.214642, longitude: 63.631868), latitudinalMeters: 6000, longitudinalMeters: 6000)
            case .PAVLODAR:
                return MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 52.285579, longitude: 76.941204), latitudinalMeters: 6000, longitudinalMeters: 6000)
            case .RIDDER:
                return MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 50.347213, longitude: 83.503283), latitudinalMeters: 6000, longitudinalMeters: 6000)
            case .SEMEI:
                return MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 50.405044, longitude: 80.24929), latitudinalMeters: 6000, longitudinalMeters: 6000)
            case .TALDYKORGAN:
                return MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 45.01363, longitude: 78.381314), latitudinalMeters: 6000, longitudinalMeters: 6000)
            case .URALSK:
                return MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 51.203959, longitude: 51.370515), latitudinalMeters: 6000, longitudinalMeters: 6000)
            case .SHYMKENT:
                return MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 42.315448, longitude: 69.587038), latitudinalMeters: 6000, longitudinalMeters: 6000)
            }
        }
    }
    
    private struct CityList: View {
        @EnvironmentObject var exchangerViewModel: ExchangerViewModel
        @EnvironmentObject var locationViewModel: LocationViewModel
        @Environment(\.dismiss) var dismiss
        
        @Binding var cameraPosition: MapCameraPosition
        @Binding var selectedCity: City
        @Binding var openCityList: Bool
        
        var body: some View {
            NavigationStack {
                List(City.allCases, id:\.title) { city in
                    HStack {
                        Text(city.title)
                        Spacer()
                        Image(systemName: selectedCity == city ? "checkmark.circle.fill" : "circle")
                            .foregroundStyle(selectedCity == city ? .blue : .primary)
                    }
                    .onTapGesture {
                        DispatchQueue.main.async {
                            withAnimation {
                                selectedCity = city
                                openCityList.toggle()
                                cameraPosition = .region(selectedCity.regionCoordinate)
                            }
                            Task {
                                await exchangerViewModel.fetchKursKz(city: selectedCity.cityForFetch)
                            }
                        }
                    }
                }
                .listStyle(.plain)
                .navigationTitle("main_available_cities")
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
    MapView()
        .environmentObject(ExchangerViewModel())
        .environmentObject(LocationViewModel())
}
