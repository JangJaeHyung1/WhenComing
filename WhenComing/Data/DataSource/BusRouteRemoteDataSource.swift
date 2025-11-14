//
//  BusRouteRemoteDataSource.swift
//  WhenComing
//
//  Created by jh on 9/16/25.
//

import Foundation

protocol BusRouteRemoteDataSource {
    func getBusRouteInfoList(pageNo: Int, cityCode: String, routeId: String) async throws -> [BusRouteInfoDTO]
    func getBusRouteList(cityCode: String, routeNo: String) async throws -> [BusRouteDTO]
}

final class DefaultBusRouteRemoteDataSource: BusRouteRemoteDataSource {
    
    
    private let networkService: NetworkServiceProtocol

    init(networkService: NetworkServiceProtocol) {
        self.networkService = networkService
    }
    
    func getBusRouteInfoList(pageNo: Int, cityCode: String, routeId: String) async throws -> [BusRouteInfoDTO] {
        try await networkService.request(.getBusRouteInfoList(pageNo: pageNo, cityCode: cityCode, routeId: routeId), type: BusRouteInfoResponseDTO.self).response.body.items.item
    }

    func getBusRouteList(cityCode: String, routeNo: String) async throws -> [BusRouteDTO] {
        try await networkService.request(.getBusRouteList(cityCode: cityCode, routeNo: routeNo), type: BusRouteListResponseDTO.self).response.body.items.item
    }
}
