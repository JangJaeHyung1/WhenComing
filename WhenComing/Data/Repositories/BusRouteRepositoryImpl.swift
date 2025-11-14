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

    func fetchBusRouteInfo(pageNo: Int, cityCode: String, routeId: String) async throws -> [BusRouteInfoEntity] {
        try await remoteDataSource.getBusRouteInfoList(pageNo: pageNo, cityCode: cityCode, routeId: routeId).map { $0.toEntity() }
    }
    
    func fetchBusRoute(cityCode: String, routeNo: String) async throws -> [BusRouteEntity] {
        try await remoteDataSource.getBusRouteList(cityCode: cityCode, routeNo: routeNo).map { $0.toEntity() }
    }
    
}
