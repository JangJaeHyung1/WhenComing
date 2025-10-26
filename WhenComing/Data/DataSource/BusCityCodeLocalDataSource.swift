//
//  BusCityCodeLocalDataSource.swift
//  WhenComing
//
//  Created by jh on 10/26/25.
//

import Foundation

protocol BusCityCodeLocalDataSource {
    func loadCityCode() -> Int?
    func saveCityCode(_ code: Int)
}

final class UserBusCityCodeLocalDataSource: BusCityCodeLocalDataSource {
    private let key = "selected_city_code"

    func loadCityCode() -> Int? {
        if let v = UserDefaults.standard.object(forKey: key) as? Int {
            return v
        }
        return nil
    }

    func saveCityCode(_ code: Int) {
        UserDefaults.standard.set(code, forKey: key)
    }
}
