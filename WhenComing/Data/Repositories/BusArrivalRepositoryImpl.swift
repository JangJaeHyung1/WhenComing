//
//  DefaultBusArrivalRepository.swift
//  WhenComing
//
//  Created by jh on 2/26/25.
//

import Foundation

final class DefaultBusArrivalRepository: BusArrivalRepositoryProtocol {
    private let remoteDataSource: BusArrivalRemoteDataSource

    init(remoteDataSource: BusArrivalRemoteDataSource) {
        self.remoteDataSource = remoteDataSource
    }

    func fetchSpecificBusArrival(pageNo: Int, cityCode: String, stationId: String, routeId: String) async throws -> [SpecificBusArrivalEntity] {
        try await remoteDataSource.getSpecificBusArrival(pageNo: pageNo, cityCode: cityCode, stationId: stationId, routeId: routeId).map { $0.toEntity() }
    }
    
    func fetchArrivalInfoList(cityCode: String, nodeId: String) async throws -> [BusStationArrivalInfoEntity] {
        try await remoteDataSource.getArrivalInfoList(cityCode: cityCode, nodeId: nodeId).map { $0.toEntity() }
    }
}
