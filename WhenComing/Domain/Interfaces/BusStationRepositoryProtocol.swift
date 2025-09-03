//
//  BusRepository.swift
//  WhenComing
//
//  Created by jh on 3/18/25.
//

import Foundation

protocol BusStationRepository {
    func fetchCityCodeList() async throws -> [CityCodeEntity]
    func fetchStationList(pageNo: Int, cityCode: String, stationName: String) async throws -> [BusStationEntity]
}
