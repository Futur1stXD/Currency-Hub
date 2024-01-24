//
//  SortSettings.swift
//  CurrencyHub
//
//  Created by Abylaykhan Myrzakhanov on 24.01.2024.
//

import Foundation

enum SortSettings: String, CaseIterable {
    case ALL, CURRENCY, LAST_UPDATE
    
    var title: String {
        switch self {
        case .LAST_UPDATE:
            return "По обновлению валюты"
        case .CURRENCY:
            return "Валюта"
        case .ALL:
            return "Все обменники"
        }
    }
}

enum SortSetBuyOrSell: String, CaseIterable {
    case BUY, SELL
    
    var title: String {
        switch self {
        case .BUY:
            return "Покупка"
        case .SELL:
            return "Продажа"
        }
    }
}
