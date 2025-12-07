//
//  GetSpecificBusArrivalUseCase.swift
//  WhenComing
//
//  Created by jh on 2/26/25.
//

import Foundation

// MARK: - Protocol
protocol GetSpecificBusArrivalUseCase {
    func execute(pageNo: Int, cityCode: String, stationId: String, routeId: String) async throws -> [SpecificBusArrivalEntity]
}

// MARK: - Implementation
final class DefaultSpecificBusArrivalUseCase: GetSpecificBusArrivalUseCase {
    private let repository: BusArrivalRepositoryProtocol

    init(repository: BusArrivalRepositoryProtocol) {
        self.repository = repository
    }

    func execute(pageNo: Int, cityCode: String, stationId: String, routeId: String) async throws -> [SpecificBusArrivalEntity] {
        try await repository.fetchSpecificBusArrival(pageNo: pageNo, cityCode: cityCode, stationId: stationId, routeId: routeId)
    }
}

