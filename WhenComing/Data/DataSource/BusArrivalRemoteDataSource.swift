//
//  BusAPIService.swift
//  WhenComing
//
//  Created by jh on 3/18/25.
//

import Foundation

protocol BusArrivalRemoteDataSource {
    func getSpecificBusArrival(pageNo: Int, cityCode: String, stationId: String, routeId: String) async throws -> [SpecificBusArrivalDTO]
}

final class DefaultBusArrivalRemoteDataSource: BusArrivalRemoteDataSource {
    private let networkService: NetworkServiceProtocol

    init(networkService: NetworkServiceProtocol) {
        self.networkService = networkService
    }
    
    func getSpecificBusArrival(pageNo: Int, cityCode: String, stationId: String, routeId: String) async throws -> [SpecificBusArrivalDTO] {
        try await networkService.request(.getSpecificBusArrival(pageNo: pageNo, cityCode: cityCode, stationId: stationId, routeId: routeId), type: SpecificBusArrivalResponseDTO.self).response.body.items.item
    }
}
