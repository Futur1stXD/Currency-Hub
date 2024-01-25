//
//  ExchnagerViewModel.swift
//  CurrencyHub
//
//  Created by Abylaykhan Myrzakhanov on 20.01.2024.
//

import Foundation
import SwiftSoup
import Combine

@MainActor
class ExchangerViewModel: ObservableObject {
    @Published var exchangers = [Exchanger]()
    @Published var error: Bool = false
    @Published var errorMessage: String = ""
    
    private var cancellables: Set<AnyCancellable> = []
    
    func fetchKursKz(city: String) async {
        guard let url = URL(string: "https://kurs.kz/site/index?city=\(city)") else { return }
        
        URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .map { data in
                String(data: data, encoding: .utf8) ?? ""
            }
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    DispatchQueue.main.async {
                        self.error.toggle()
                        self.errorMessage = error.localizedDescription
                    }
                }
            }, receiveValue: { [weak self] html in
                guard let exchangers = self?.extractJSON(from: html, city: city) else { return }
                self?.exchangers = exchangers
            })
            .store(in: &cancellables)
    }
    
    private func extractJSON(from html: String, city: String) -> [Exchanger] {
        do {
            let doc = try SwiftSoup.parse(html)
            let scriptElements = try doc.select("script").array()
            
            var jsonDataStrings: [String] = []

            for scriptElement in scriptElements {
                let scriptText = try scriptElement.html()
                let patterns = city == "almaty" ? ["var punktsFromInternet = (\\[\\{.*?\\}\\]);", "var punkts = (\\[\\{.*?\\}\\]);"] : ["var punkts = (\\[\\{.*?\\}\\]);"]
                for pattern in patterns {
                    let regex = try NSRegularExpression(pattern: pattern, options: [])
                    if let match = regex.firstMatch(in: scriptText, options: [], range: NSRange(location: 0, length: scriptText.utf16.count)) {
                        let range = Range(match.range(at: 1), in: scriptText)!
                        jsonDataStrings.append(String(scriptText[range]))
                    }
                }
            }
            var allExchangers = [Exchanger]()
            for jsonDataString in jsonDataStrings {
                if let data = jsonDataString.data(using: .utf8) {
                    do {
                        let exchangers = try JSONDecoder().decode([ExchangerJSON].self, from: data)
                        for exchanger in exchangers {
                            let timestamp: TimeInterval = exchanger.actualTime
                            let date = Date(timeIntervalSince1970: timestamp)
                            let arrCurrencies = convertToCurrencies(exchanger.data)
                            let newExchanger = Exchanger(id: String(exchanger.id), title: exchanger.name, city: exchanger.city, mainAddress: exchanger.mainaddress, address: exchanger.address, phones: exchanger.phones, actualTime: date, coordinates: Coordinates(lat: exchanger.lat, lng: exchanger.lng), currency: arrCurrencies, workModes: exchanger.workmodes, type: .EXCHANGER, source: .KURS)
                            allExchangers.append(newExchanger)
                        }
                    } catch {
                        DispatchQueue.main.async {
                            self.error.toggle()
                            self.errorMessage = error.localizedDescription
                        }
                    }
                }
            }

            return allExchangers

        } catch {
            DispatchQueue.main.async {
                self.error.toggle()
                self.errorMessage = error.localizedDescription
            }
        }
        return []
    }

    
    private func convertToCurrencies(_ dict: [String: [Double]]) -> [Currencies] {
        return dict.compactMap { key, values in
            guard values.count >= 2, values[0] != 0, values[1] != 0 else { return nil }
            return Currencies(title: key, buyPrice: values[0], sellPrice: values[1])
        }
    }
}
