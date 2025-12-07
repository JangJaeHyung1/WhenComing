//
//  GetBusRouteListUseCase.swift
//  WhenComing
//
//  Created by jh on 11/15/25.
//

import Foundation

// MARK: - Protocol
protocol GetBusRouteListUseCase {
    func execute(cityCode: String, routeNo: String) async throws -> [BusRouteEntity]
}

// MARK: - Implementation
final class DefaultGetBusRouteListUseCase: GetBusRouteListUseCase {
    private let repository: BusRouteRepositoryProtocol

    init(repository: BusRouteRepositoryProtocol) {
        self.repository = repository
    }

    func execute(cityCode: String, routeNo: String) async throws -> [BusRouteEntity] {
        try await repository.fetchBusRoute(cityCode: cityCode, routeNo: routeNo)
    }
}
