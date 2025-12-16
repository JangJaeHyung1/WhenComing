//
//  BusStationRepositoryProtocol.swift
//  WhenComing
//
//  Created by jh on 3/18/25.
//

import Foundation

protocol BusStationRepositoryProtocol {
    func fetchCityCodeList() async throws -> [BusCityCodeEntity]
    func fetchStationList(pageNo: Int, cityCode: String, stationName: String) async throws -> [BusStationEntity]
    func fetchNearbyStationList(pageNo: Int, latitude: Double, longitude: Double) async throws -> [AroundBusStationEntity]
    func fetchStationThrghBusList(cityCode: String, nodeId: String) async throws -> [StationThrghBusEntity]
}
