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
    
    @State private var selectedExchangerId: String?
    @State private var selectedExchanger: Exchanger?
    @State private var openDetailSheet: Bool = false
    @State private var heightDetailView: CGFloat = 0
    
    var body: some View {
        ZStack {
            Map(position: $cameraPosition, selection: $selectedExchangerId) {
                UserAnnotation()
                ForEach(exchangerViewModel.exchangers, id: \.id) { exchanger in
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
            ExchangerList(openSearchList: $openSearchList, selectedExchanger: $selectedExchangerId)
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
                return "Алматы"
            case .ASTANA:
                return "Астана"
            case .AKSU:
                return "Аксу"
            case .AKTAU:
                return "Актау"
            case .AKTOBE:
                return "Актобе"
            case .KASKELEN:
                return "Каскелен"
            case .KOSTANAI:
                return "Костанай"
            case .PAVLODAR:
                return "Павлодар"
            case .RIDDER:
                return "Риддер"
            case .SEMEI:
                return "Семей"
            case .TALDYKORGAN:
                return "Талдыкорган"
            case .URALSK:
                return "Уральск"
            case .SHYMKENT:
                return "Шымкент"
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
                .navigationTitle("Доступные города")
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
