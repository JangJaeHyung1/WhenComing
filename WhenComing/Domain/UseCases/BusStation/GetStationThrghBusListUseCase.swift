//
//  GetStationThrghBusList.swift
//  WhenComing
//
//  Created by jh on 3/18/25.
//

import Foundation

// MARK: - Protocol
protocol GetStationThrghBusListUseCase {
    func execute(pageNo: Int, cityCode: String, nodeId: String) async throws -> [StationThrghBusEntity]
}

// MARK: - Implementation
final class DefaultGetStationThrghBusListUseCase: GetStationThrghBusListUseCase {
    private let repository: BusStationRepositoryProtocol

    init(repository: BusStationRepositoryProtocol) {
        self.repository = repository
    }

    func execute(pageNo: Int, cityCode: String, nodeId: String) async throws -> [StationThrghBusEntity] {
        try await repository.fetchStationThrghBusList(pageNo: pageNo, cityCode: cityCode, nodeId: nodeId)
    }
}
