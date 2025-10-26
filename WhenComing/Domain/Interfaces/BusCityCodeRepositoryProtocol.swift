//
//  BusCityCodeRepositoryProtocol.swift
//  WhenComing
//
//  Created by jh on 10/26/25.
//

protocol BusCityCodeRepositoryProtocol {
    func loadCityCode() -> Int?
    func saveCityCode(_ code: Int)
}
