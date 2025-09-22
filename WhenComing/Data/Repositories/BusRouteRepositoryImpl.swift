//
//  BusRouteRepositoryImpl.swift
//  WhenComing
//
//  Created by jh on 9/16/25.
//

final class DefaultBusRouteRepository: BusRouteRepositoryProtocol {
    
    private let remoteDataSource: BusRouteRemoteDataSource

    init(remoteDataSource: BusRouteRemoteDataSource) {
        self.remoteDataSource = remoteDataSource
    }

    func fetchBusRoute(pageNo: Int, cityCode: String, stationId: String, routeId: String) async throws -> [BusRouteInfoEntity] {
        try await remoteDataSource.getBusRouteList(pageNo: pageNo, cityCode: cityCode, routeId: routeId).map { $0.toEntity() }
    }
}
