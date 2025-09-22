//
//  BusRouteRemoteDataSource.swift
//  WhenComing
//
//  Created by jh on 9/16/25.
//

import Foundation

protocol BusRouteRemoteDataSource {
    func getBusRouteList(pageNo: Int, cityCode: String, routeId: String) async throws -> [BusRouteInfoDTO]
}

final class DefaultBusRouteRemoteDataSource: BusRouteRemoteDataSource {
    
    
    private let networkService: NetworkServiceProtocol

    init(networkService: NetworkServiceProtocol) {
        self.networkService = networkService
    }
    
    func getBusRouteList(pageNo: Int, cityCode: String, routeId: String) async throws -> [BusRouteInfoDTO] {
        try await networkService.request(.getBusRouteList(pageNo: pageNo, cityCode: cityCode, routeId: routeId), type: BusRouteInfoResponseDTO.self).response.body.items.item
    }

}
