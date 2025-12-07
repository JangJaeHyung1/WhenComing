//
//  GetNearbyStationListUseCase.swift
//  WhenComing
//
//  Created by jh on 9/22/25.
//

import Foundation

// MARK: - Protocol
protocol GetNearbyStationListUseCase {
    func execute(pageNo: Int, lat: Double, lng: Double) async throws -> [AroundBusStationEntity]
}

// MARK: - Implementation
final class DefaultGetNearbyStationListUseCase: GetNearbyStationListUseCase {
    private let repository: BusStationRepositoryProtocol

    init(repository: BusStationRepositoryProtocol) {
        self.repository = repository
    }

    func execute(pageNo: Int, lat: Double, lng: Double) async throws -> [AroundBusStationEntity] {
        try await repository.fetchNearbyStationList(pageNo: pageNo, latitude: lat, longitude: lng)
    }
}

