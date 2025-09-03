//
//  BusStationRemoteDataSource.swift
//  WhenComing
//
//  Created by jh on 5/13/25.
//

import Foundation

protocol BusStationRemoteDataSource {
    func getCityCodeList() async throws -> [CityCodeDTO]
    func getStationList(pageNo: Int, cityCode: String, stationName: String) async throws -> [BusStationDTO]
}

final class DefaultBusStationRemoteDataSource: BusStationRemoteDataSource {
    private let networkService: NetworkServiceProtocol

    init(networkService: NetworkServiceProtocol) {
        self.networkService = networkService
    }

    func getCityCodeList() async throws -> [CityCodeDTO] {
        let result = try await networkService.request(.getCityCodeList, type: CityCodeListResponseDTO.self)
        return result.response.body.items.item
    }

    func getStationList(pageNo: Int, cityCode: String, stationName: String) async throws -> [BusStationDTO] {
        try await networkService.request(.getStationList(pageNo: pageNo, cityCode: cityCode, stationName: stationName), type: StationListResponseDTO.self).response.body.items.item
    }
}
