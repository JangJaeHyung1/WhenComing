//
//  BusAPIService.swift
//  WhenComing
//
//  Created by jh on 3/18/25.
//

import Foundation

protocol BusArrivalRemoteDataSource {
    func getSpecificBusArrival(pageNo: Int, cityCode: String, stationId: String, routeId: String) async throws -> [SpecificBusArrivalDTO]
    func getArrivalInfoList(pageNo: Int, cityCode: String, nodeId: String) async throws -> [BusStationArrivalInfoDTO]
}

final class DefaultBusArrivalRemoteDataSource: BusArrivalRemoteDataSource {
    private let networkService: NetworkServiceProtocol

    init(networkService: NetworkServiceProtocol) {
        self.networkService = networkService
    }
    
    func getSpecificBusArrival(pageNo: Int, cityCode: String, stationId: String, routeId: String) async throws -> [SpecificBusArrivalDTO] {
        try await networkService.request(.getSpecificBusArrival(pageNo: pageNo, cityCode: cityCode, stationId: stationId, routeId: routeId), type: SpecificBusArrivalResponseDTO.self).response.body.items.item
    }
    
    func getArrivalInfoList(pageNo: Int, cityCode: String, nodeId: String) async throws -> [BusStationArrivalInfoDTO] {
        try await networkService.request(.getArrivalInfoList(pageNo: pageNo, cityCode: cityCode, nodeId: nodeId), type: BusStationArrivalInfoListResponseDTO.self).response.body.items
    }
}
