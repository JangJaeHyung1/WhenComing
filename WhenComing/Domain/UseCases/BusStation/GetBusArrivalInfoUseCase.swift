//
//  GetBusArrivalInfoUseCase.swift
//  WhenComing
//
//  Created by jh on 12/7/25.
//

import Foundation

// MARK: - Protocol
protocol GetBusArrivalInfoUseCase {
    func execute(pageNo: Int, stationId: String) async throws -> [BusStationArrivalInfoEntity]
}

// MARK: - Implementation
final class DefaultGetBusArrivalInfoUseCase: GetBusArrivalInfoUseCase {
    private let repository: BusArrivalRepositoryProtocol

    init(repository: BusArrivalRepositoryProtocol) {
        self.repository = repository
    }

    func execute(pageNo: Int, stationId: String) async throws -> [BusStationArrivalInfoEntity] {
        try await repository.fetchArrivalInfoList(pageNo: pageNo, stationId: stationId)
    }
}
