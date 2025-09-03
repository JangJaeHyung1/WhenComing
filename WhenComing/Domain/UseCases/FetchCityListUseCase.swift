//
//  FetchBusListUseCase.swift
//  WhenComing
//
//  Created by jh on 3/18/25.
//

import Foundation

// MARK: - Protocol
protocol FetchCityCodeListUseCase {
    func execute() async throws -> [CityCodeEntity]
}

// MARK: - Implementation
final class DefaultFetchCityCodeListUseCase: FetchCityCodeListUseCase {
    private let repository: BusStationRepository

    init(repository: BusStationRepository) {
        self.repository = repository
    }

    func execute() async throws -> [CityCodeEntity] {
        try await repository.fetchCityCodeList()
    }
}
