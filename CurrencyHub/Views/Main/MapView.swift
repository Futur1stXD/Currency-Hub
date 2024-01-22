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
        .onAppear {
            cameraPosition = .region(locationViewModel.region)
            
            if exchangerViewModel.exchangers.count == 0 {
                Task {
                    await exchangerViewModel.fetchKursKz()
                }
            }
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
}

#Preview {
    MapView()
        .environmentObject(ExchangerViewModel())
        .environmentObject(LocationViewModel())
}
