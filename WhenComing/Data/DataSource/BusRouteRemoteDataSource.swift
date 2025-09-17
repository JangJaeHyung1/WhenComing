//
//  BusRouteRemoteDataSource.swift
//  WhenComing
//
//  Created by jh on 9/16/25.
//

import Foundation

protocol BusRouteRemoteDataSource {
    func getSttnThrghRouteList(pageNo: Int, cityCode: String, nodeId: String) async throws -> [StationThrghBusDTO]
}

final class DefaultBusRouteRemoteDataSource: BusRouteRemoteDataSource {
    
    
    private let networkService: NetworkServiceProtocol

    init(networkService: NetworkServiceProtocol) {
        self.networkService = networkService
    }
    
    func getSttnThrghRouteList(pageNo: Int, cityCode: String, nodeId: String) async throws -> [StationThrghBusDTO] {
        try await networkService.request(.getSttnThrghRouteList(pageNo: pageNo, cityCode: cityCode, nodeId: nodeId), type: StationThrghRouteListResponseDTO.self).response.body.items.item
    }

}
