//
//  GetBusRouteListUseCase.swift
//  WhenComing
//
//  Created by jh on 9/22/25.
//

import Foundation

// MARK: - Protocol
protocol GetBusRouteListUseCase {
    func execute(pageNo: Int, cityCode: String, stationId: String, routeId: String) async throws -> [BusRouteInfoEntity]
}

// MARK: - Implementation
final class DefaultGetBusRouteListUseCase: GetBusRouteListUseCase {
    private let repository: BusRouteRepositoryProtocol

    init(repository: BusRouteRepositoryProtocol) {
        self.repository = repository
    }

    func execute(pageNo: Int, cityCode: String, stationId: String, routeId: String) async throws -> [BusRouteInfoEntity] {
        try await repository.fetchBusRoute(pageNo: pageNo, cityCode: cityCode, stationId: stationId, routeId: routeId)
    }
}

