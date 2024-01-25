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
            return NSLocalizedString("main_sort_update", comment: "")
        case .CURRENCY:
            return NSLocalizedString("main_sort_currency", comment: "")
        case .ALL:
            return NSLocalizedString("main_sort_all", comment: "")
        }
    }
}

enum SortSetBuyOrSell: String, CaseIterable {
    case BUY, SELL
    
    var title: String {
        switch self {
        case .BUY:
            return NSLocalizedString("main_buy", comment: "")
        case .SELL:
            return NSLocalizedString("main_sell", comment: "")
        }
    }
}
