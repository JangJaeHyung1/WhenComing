//
//  BusCityCodeRepository.swift
//  WhenComing
//
//  Created by jh on 10/26/25.
//


import Foundation

final class DefaultBusCityCoedRepository: BusCityCodeRepositoryProtocol {

    private let remoteDataSource: BusCityCodeLocalDataSource

    init(remoteDataSource: BusCityCodeLocalDataSource) {
        self.remoteDataSource = remoteDataSource
    }

    func loadCityCode() -> Int? {
        remoteDataSource.loadCityCode()
    }

    func saveCityCode(_ code: Int) {
        remoteDataSource.saveCityCode(code)
    }
}
