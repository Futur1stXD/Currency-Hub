//
//  ContentView.swift
//  CurrencyHub
//
//  Created by Abylaykhan Myrzakhanov on 20.01.2024.
//

import SwiftUI

struct ContentView: View {
    @StateObject var exchangerViewModel: ExchangerViewModel = ExchangerViewModel()
    
    @State private var isAnimated: Bool = false
    
    var body: some View {
        TabView {
            MapView()
                .environmentObject(exchangerViewModel)
                .tabItem {
                    Label(
                        title: { Text("main_map") },
                        icon: {
                            Image(systemName: "map.fill")
                        }
                    )
                    .onTapGesture {
                        self.isAnimated.toggle()
                    }
                }
                .tag(0)
            
            About()
                .tabItem {
                    Label(
                        title: { Text("about_of_application") },
                        icon: { 
                            Image(systemName: "info.square.fill")
                        }
                    )
                }
                .tag(1)
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(LocationViewModel())
        .environmentObject(ExchangerViewModel())
}
