//
//  FetchBusListUseCase.swift
//  WhenComing
//
//  Created by jh on 3/18/25.
//

import Foundation

// MARK: - Protocol
protocol FetchCityCodeListUseCase {
    func execute() async throws -> [BusCityCodeEntity]
}

// MARK: - Implementation
final class DefaultFetchCityCodeListUseCase: FetchCityCodeListUseCase {
    private let repository: BusStationRepositoryProtocol

    init(repository: BusStationRepositoryProtocol) {
        self.repository = repository
    }

    func execute() async throws -> [BusCityCodeEntity] {
        try await repository.fetchCityCodeList()
    }
}
