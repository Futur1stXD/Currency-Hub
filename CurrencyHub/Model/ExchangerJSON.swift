//
//  Exchanger.swift
//  CurrencyHub
//
//  Created by Abylaykhan Myrzakhanov on 20.01.2024.
//

import Foundation

struct ExchangerJSON: Identifiable, Decodable {
    let id: Int
    
    let name: String
    let city: String
    let mainaddress: String
    let address: String
    let phones: [String]
    let actualTime: Date
    
    let lat: Double
    let lng: Double
    
    let workmodes: Workmodes
    let data: [String: [Double]]
    
    init(id: Int, name: String, city: String, mainaddress: String, address: String, phones: [String], actualTime: Date, lat: Double, lng: Double, workmodes: Workmodes, data: [String : [Double]]) {
        self.id = id
        self.name = name
        self.city = city
        self.mainaddress = mainaddress
        self.address = address
        self.phones = phones
        self.actualTime = actualTime
        self.lat = lat
        self.lng = lng
        self.workmodes = workmodes
        self.data = data
    }
}

struct Workmodes: Codable {
    let mon, tue, wed, thu: [String]
    let fri, sat, sun, holyday: [String]
    let nonstop, closed, worknow: Bool
}
