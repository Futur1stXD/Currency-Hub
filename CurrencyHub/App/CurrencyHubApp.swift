//
//  CurrencyHubApp.swift
//  CurrencyHub
//
//  Created by Abylaykhan Myrzakhanov on 20.01.2024.
//

import SwiftUI

@main
struct CurrencyHubApp: App {
    @StateObject var locationViewModel: LocationViewModel = LocationViewModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(locationViewModel)
        }
    }
}
