//
//  BusCityCodeRepository.swift
//  WhenComing
//
//  Created by jh on 10/26/25.
//


import Foundation

final class DefaultBusCityCodeRepository: BusCityCodeRepositoryProtocol {

    private let localDataSource: BusCityCodeLocalDataSource

    init(localDataSource: BusCityCodeLocalDataSource) {
        self.localDataSource = localDataSource
    }

    func loadCityCode() -> Int? {
        localDataSource.loadCityCode()
    }

    func saveCityCode(_ code: Int) {
        localDataSource.saveCityCode(code)
    }
}
