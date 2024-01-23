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
    @Published var isUpdating: Bool = false
    
    private var cancellables: Set<AnyCancellable> = []
    
    func fetchKursKz() async {
        guard let url = URL(string: "https://kurs.kz/site/index?city=astana") else { return }
        
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
                    print("Error: \(error)")
                }
            }, receiveValue: { [weak self] html in
                guard let exchangers = self?.extractJSON(from: html) else { return }
                self?.exchangers = exchangers
            })
            .store(in: &cancellables)
    }
    
    func updateKursKz(id: String) async {
        if isUpdating { return }
        isUpdating = true
        guard let url = URL(string: "https://kurs.kz/site/index?city=astana") else { return }
        
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
                    print("Error: \(error)")
                }
            }, receiveValue: { [weak self] html in
                guard let exchangers = self?.extractJSON(from: html) else { return }
                if let exchanger = exchangers.first(where: { $0.id == id }) {
                    if let index = self?.exchangers.firstIndex(where: { $0.id == id }) {
                        DispatchQueue.main.async {
                            self?.exchangers[index].currency = exchanger.currency
                            self?.exchangers[index].actualTime = exchanger.actualTime
                            self?.isUpdating = false
                        }
                    }
                }
            })
            .store(in: &cancellables)
    }
    
    private func extractJSON(from html: String) -> [Exchanger] {
        do {
            let doc = try SwiftSoup.parse(html)
            if let scriptElement = try doc.select("script").first(where: { try $0.html().contains("var punkts =")}) {
                let scriptText = try scriptElement.html()
                let pattern = "var punkts = (\\[\\{.*?\\}\\]);"
                let regex = try NSRegularExpression(pattern: pattern, options: [])
                if let match = regex.firstMatch(in: scriptText, options: [], range: NSRange(location: 0, length: scriptText.utf16.count)) {
                    let range = Range(match.range(at: 1), in: scriptText)!
                    let jsonString = String(scriptText[range])
                    if let data = jsonString.data(using: .utf8) {
                        do {
                            let exchangers = try JSONDecoder().decode([ExchangerJSON].self, from: data)
                            var newArray = [Exchanger]()
                            for exchanger in exchangers {
                                let timestamp: TimeInterval = exchanger.actualTime
                                let date = Date(timeIntervalSince1970: timestamp)
                                let arrCurrencies = convertToCurrencies(exchanger.data)
                                let newExchanger = Exchanger(id: String(exchanger.id), title: exchanger.name, city: exchanger.city, mainAddress: exchanger.mainaddress, address: exchanger.address, phones: exchanger.phones, actualTime: date, coordinates: Coordinates(lat: exchanger.lat, lng: exchanger.lng), currency: arrCurrencies, workModes: exchanger.workmodes, type: .EXCHANGER, source: .KURS)
                                newArray.append(newExchanger)
                            }
                            if exchangers.count == newArray.count {
                                return newArray
                            }
                        } catch {
                            print("Error decoding JSON: \(error)")
                        }
                    }
                }
            }
        } catch {
            print("Error extracting JSON: \(error)")
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
