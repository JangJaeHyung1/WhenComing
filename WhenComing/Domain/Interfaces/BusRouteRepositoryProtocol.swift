//
//  BusRouteRepositoryProtocol.swift
//  WhenComing
//
//  Created by jh on 9/16/25.
//

protocol BusRouteRepositoryProtocol {
    func fetchBusRouteInfo(pageNo: Int, cityCode: String, routeId: String) async throws -> [BusRouteInfoEntity]
    func fetchBusRoute(cityCode: String, routeNo: String) async throws -> [BusRouteEntity]
}
