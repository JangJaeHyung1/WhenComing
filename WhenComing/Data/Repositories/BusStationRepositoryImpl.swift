//
//  BusRepository.swift
//  WhenComing
//
//  Created by jh on 2/26/25.
//

import Foundation

final class DefaultBusStationRepository: BusStationRepositoryProtocol {
    private let remoteDataSource: BusStationRemoteDataSource

    init(remoteDataSource: BusStationRemoteDataSource) {
        self.remoteDataSource = remoteDataSource
    }

    func fetchCityCodeList() async throws -> [BusCityCodeEntity] { // dto 말고 entity로 변환해야함
        try await remoteDataSource.getCityCodeList().map { $0.toEntity() }
    }

    func fetchStationList(pageNo: Int, cityCode: String, stationName: String) async throws -> [BusStationEntity] {
        try await remoteDataSource.getStationList(pageNo: pageNo, cityCode: cityCode, stationName: stationName).map { $0.toEntity() }
    }
    
    func fetchNearbyStationList(pageNo: Int, latitude: Double, longitude: Double) async throws -> [AroundBusStationEntity] {
        try await remoteDataSource.getAroundStationList(pageNo: pageNo, lat: latitude, lng: longitude).map { $0.toEntity() }
    }
    
    func fetchStationThrghBusList(cityCode: String, nodeId: String) async throws -> [StationThrghBusEntity] {
        try await remoteDataSource.getSttnThrghRouteList(cityCode: cityCode, nodeId: nodeId).map { $0.toEntity() }
    }
    
}
