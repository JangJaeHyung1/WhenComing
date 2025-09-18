//
//  BusRouteRepositoryImpl.swift
//  WhenComing
//
//  Created by jh on 9/16/25.
//

final class DefaultBusRouteRepository: BusRouteRepositoryProtocol {
    
    private let remoteDataSource: BusArrivalRemoteDataSource

    init(remoteDataSource: BusArrivalRemoteDataSource) {
        self.remoteDataSource = remoteDataSource
    }

    func fetchBusRoute(pageNo: Int, cityCode: String, stationId: String, routeId: String) async throws -> [SpecificBusArrivalEntity] {
        try await remoteDataSource.getSpecificBusArrival(pageNo: pageNo, cityCode: cityCode, stationId: stationId, routeId: routeId).map { $0.toEntity() }
    }
}
