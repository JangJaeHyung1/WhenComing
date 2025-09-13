//
//  BusAPIService.swift
//  WhenComing
//
//  Created by jh on 3/18/25.
//

import Foundation

protocol BusArrivalRemoteDataSource {
    func getArrivalInfoList(pageNo: Int, stationId: String) async throws -> [BusArrivalDTO]
    func getSpecificBusArrival(cityCode: String, stationId: String, routeId: String) async throws -> [BusInfoDTO]
}


final class DefaultBusArrivalRemoteDataSource: BusArrivalRemoteDataSource {
    private let networkService: NetworkServiceProtocol

    init(networkService: NetworkServiceProtocol) {
        self.networkService = networkService
    }

    func getArrivalInfoList(pageNo: Int, stationId: String) async throws -> [BusArrivalDTO] {
        try await networkService.request(.getArrivalInfoList(pageNo: pageNo, stationId: stationId), type: [BusArrivalDTO].self)
    }

    func getSpecificBusArrival(cityCode: String, stationId: String, routeId: String) async throws -> [BusInfoDTO] {
        try await networkService.request(.getSpecificBusArrival(cityCode: cityCode, stationId: stationId, routeId: routeId), type: [BusInfoDTO].self)
    }
}
