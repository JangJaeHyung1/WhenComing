//
//  SearchStationByNameUseCase.swift
//  WhenComing
//
//  Created by jh on 8/19/25.
//

import Foundation

// MARK: - Protocol
protocol SearchStationByNameUseCase {
    func execute(pageNo: Int, cityCode: String, stationName: String) async throws -> [BusStationEntity]
}

// MARK: - Implementation
final class DefaultSearchStationByNameUseCase: SearchStationByNameUseCase {
    private let repository: BusStationRepositoryProtocol

    init(repository: BusStationRepositoryProtocol) {
        self.repository = repository
    }

    func execute(pageNo: Int, cityCode: String, stationName: String) async throws -> [BusStationEntity] {
        try await repository.fetchStationList(pageNo: pageNo, cityCode: cityCode, stationName: stationName)
    }
}

