//
//  FetchBusStationListUseCase.swift
//  WhenComing
//
//  Created by jh on 8/19/25.
//

import Foundation

// MARK: - Protocol
protocol FetchBusStationListUseCase {
    func execute(pageNo: Int, cityCode: String, stationName: String) async throws -> [BusStationEntity]
}

// MARK: - Implementation
final class DefaultFetchBusStationListUseCase: FetchBusStationListUseCase {
    private let repository: BusStationRepository

    init(repository: BusStationRepository) {
        self.repository = repository
    }

    func execute(pageNo: Int, cityCode: String, stationName: String) async throws -> [BusStationEntity] {
        try await repository.fetchStationList(pageNo: pageNo, cityCode: cityCode, stationName: stationName)
    }
}

