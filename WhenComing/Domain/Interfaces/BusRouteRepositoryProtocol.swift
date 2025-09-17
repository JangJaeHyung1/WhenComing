//
//  BusRouteRepositoryProtocol.swift
//  WhenComing
//
//  Created by jh on 9/16/25.
//

protocol BusRouteRepositoryProtocol {
    func fetchSpecificBusArrival(cityCode: String, stationId: String, routeId: String) async throws -> [SpecificBusArrivalEntity]
}
