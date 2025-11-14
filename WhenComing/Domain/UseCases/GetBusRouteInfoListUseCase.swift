//
//  GetBusRouteInfoListUseCase.swift
//  WhenComing
//
//  Created by jh on 9/22/25.
//

import Foundation

// MARK: - Protocol
protocol GetBusRouteInfoListUseCase {
    func execute(pageNo: Int, cityCode: String, routeId: String) async throws -> [BusRouteInfoEntity]
}

// MARK: - Implementation
final class DefaultGetBusRouteInfoListUseCase: GetBusRouteInfoListUseCase {
    private let repository: BusRouteRepositoryProtocol

    init(repository: BusRouteRepositoryProtocol) {
        self.repository = repository
    }

    func execute(pageNo: Int, cityCode: String, routeId: String) async throws -> [BusRouteInfoEntity] {
        try await repository.fetchBusRouteInfo(pageNo: pageNo, cityCode: cityCode, routeId: routeId)
    }
}

