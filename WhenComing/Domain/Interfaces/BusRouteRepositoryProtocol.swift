//
//  BusRouteRepositoryProtocol.swift
//  WhenComing
//
//  Created by jh on 9/16/25.
//

protocol BusRouteRepositoryProtocol {
    func fetchBusRoute(pageNo: Int, cityCode: String, stationId: String, routeId: String) async throws -> [SpecificBusArrivalEntity]
}
