//
//  Exchanger.swift
//  CurrencyHub
//
//  Created by Abylaykhan Myrzakhanov on 20.01.2024.
//

import Foundation
import MapKit

struct Exchanger: Identifiable {
    let id: String
    
    let title: String
    let city: String
    let mainAddress: String
    let address: String
    let phones: [String]
    var actualTime: Date
    var coordinates: Coordinates
    
    var currency: [Currencies]
    let workModes: Workmodes
    
    let type: ExchangerType
    let source: ExchangerSource
}

struct Coordinates {
    let lat: Double
    let lng: Double
    var coordinates: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: lat, longitude: lng)
    }
}

struct Currencies {
    let title: String
    
    var buyPrice: Double
    var sellPrice: Double
    
    var flag: String {
        return getCurrencyName(title: self.title)
    }
    
    private func getCurrencyName(title: String) -> String {
        switch title {
        case "USD": return "🇺🇸"
        case "EUR": return "🇪🇺"
        case "RUB": return "🇷🇺"
        case "KGS": return "🇰🇬"
        case "CNY": return "🇨🇳"
        case "GBP": return "🇬🇧"
        case "CHF": return "🇨🇭"
        case "UZS": return "🇺🇿"
        case "JPY": return "🇯🇵"
        case "AUD": return "🇦🇺"
        case "TRY": return "🇹🇷"
        case "AED": return "🇦🇪"
        case "UAH": return "🇺🇦"
        case "THB": return "🇹🇭"
        case "INR": return "🇮🇳"
        case "EGP": return "🇪🇬"
        case "CAD": return "🇨🇦"
        case "KPW": return "🇰🇵"
        case "KRW": return "🇰🇷"
        case "MNT": return "🇲🇳"
        case "TMT": return "🇹🇲"
        case "GEL": return "🇬🇪"
        case "GOLD": return "🏅"
        case "AZN": return "🇦🇿"
        case "BHD": return "🇧🇭"
        case "AMD": return "🇦🇲"
        case "BYN": return "🇧🇾"
        case "BRL": return "🇧🇷"
        case "HUF": return "🇭🇺"
        case "HKD": return "🇭🇰"
        case "DKK": return "🇩🇰"
        case "IRR": return "🇮🇷"
        case "KWD": return "🇰🇼"
        case "MYR": return "🇲🇾"
        case "MXN": return "🇲🇽"
        case "MDL": return "🇲🇩"
        case "NOK": return "🇳🇴"
        case "PLN": return "🇵🇱"
        case "SAR": return "🇸🇦"
        case "XDR": return "🌐"
        case "SGD": return "🇸🇬"
        case "TJS": return "🇹🇯"
        case "CZK": return "🇨🇿"
        case "SEK": return "🇸🇪"
        case "ZAR": return "🇿🇦"
        case "ILS": return "🇮🇱"
        case "QAR": return "🇶🇦"
        case "VND": return "🇻🇳"
        case "LKR": return "🇱🇰"
        case "OMR": return "🇴🇲"
        case "PKR": return "🇵🇰"
        default: return "Неизвестная валюта"
        }
    }
}

enum ExchangerType: Decodable {
    case EXCHANGER, BANK
}

enum ExchangerSource {
    case KURS
    
    var title: String {
        switch self {
        case .KURS: return "Kurs.kz"
        }
    }
}

enum Currency: String, CaseIterable {
    case USD, EUR, RUB, KGS, CNY, GBP, CHF, UZS, JPY, AUD, TRY, AED, UAH, THB, INR, EGP, CAD, KPW, KRW, MNT, TMT, GEL, GOLD, AZN, BHD, AMD, BYN, BRL, HUF, HKD, DKK, IRR, KWD, MYR, MXN, MDL, NOK, PLN, SAR, XDR, SGD, TJS, CZK, SEK, ZAR, ILS, QAR, VND, LKR, OMR, PKR
    
    var flag: String {
        switch self {
        case .USD: return "🇺🇸"
        case .EUR: return "🇪🇺"
        case .RUB: return "🇷🇺"
        case .KGS: return "🇰🇬"
        case .CNY: return "🇨🇳"
        case .GBP: return "🇬🇧"
        case .CHF: return "🇨🇭"
        case .UZS: return "🇺🇿"
        case .JPY: return "🇯🇵"
        case .AUD: return "🇦🇺"
        case .TRY: return "🇹🇷"
        case .AED: return "🇦🇪"
        case .UAH: return "🇺🇦"
        case .THB: return "🇹🇭"
        case .INR: return "🇮🇳"
        case .EGP: return "🇪🇬"
        case .CAD: return "🇨🇦"
        case .KPW: return "🇰🇵"
        case .KRW: return "🇰🇷"
        case .MNT: return "🇲🇳"
        case .TMT: return "🇹🇲"
        case .GEL: return "🇬🇪"
        case .GOLD: return "🏅"
        case .AZN: return "🇦🇿"
        case .BHD: return "🇧🇭"
        case .AMD: return "🇦🇲"
        case .BYN: return "🇧🇾"
        case .BRL: return "🇧🇷"
        case .HUF: return "🇭🇺"
        case .HKD: return "🇭🇰"
        case .DKK: return "🇩🇰"
        case .IRR: return "🇮🇷"
        case .KWD: return "🇰🇼"
        case .MYR: return "🇲🇾"
        case .MXN: return "🇲🇽"
        case .MDL: return "🇲🇩"
        case .NOK: return "🇳🇴"
        case .PLN: return "🇵🇱"
        case .SAR: return "🇸🇦"
        case .XDR: return "🌐"
        case .SGD: return "🇸🇬"
        case .TJS: return "🇹🇯"
        case .CZK: return "🇨🇿"
        case .SEK: return "🇸🇪"
        case .ZAR: return "🇿🇦"
        case .ILS: return "🇮🇱"
        case .QAR: return "🇶🇦"
        case .VND: return "🇻🇳"
        case .LKR: return "🇱🇰"
        case .OMR: return "🇴🇲"
        case .PKR: return "🇵🇰"
        }
    }
}
