//
//  FetchCityCodeListUseCase.swift
//  WhenComing
//
//  Created by jh on 3/18/25.
//

import Foundation

// MARK: - Protocol
protocol GetCityCodeListUseCase {
    func execute() async throws -> [BusCityCodeEntity]
}

// MARK: - Implementation
final class DefaultGetCityCodeListUseCase: GetCityCodeListUseCase {
    private let repository: BusStationRepositoryProtocol

    init(repository: BusStationRepositoryProtocol) {
        self.repository = repository
    }

    func execute() async throws -> [BusCityCodeEntity] {
        try await repository.fetchCityCodeList()
    }
}
