//
//  DefaultBusArrivalRepository.swift
//  WhenComing
//
//  Created by jh on 2/26/25.
//

import Foundation

final class DefaultBusArrivalRepository: BusArrivalRepository {
    private let remoteDataSource: BusArrivalRemoteDataSource

    init(remoteDataSource: BusArrivalRemoteDataSource) {
        self.remoteDataSource = remoteDataSource
    }

    func fetchArrivalInfoList(stationId: String) async throws -> [BusArrivalDTO] {
        try await remoteDataSource.getArrivalInfoList(stationId: stationId)
    }

    func fetchSpecificBusArrival(cityCode: String, stationId: String, routeId: String) async throws -> [BusInfoDTO] {
        try await remoteDataSource.getSpecificBusArrival(cityCode: cityCode, stationId: stationId, routeId: routeId)
    }
}
