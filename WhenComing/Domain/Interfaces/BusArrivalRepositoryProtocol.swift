//
//  dsadsa.swift
//  WhenComing
//
//  Created by jh on 5/12/25.
//

import Foundation

protocol BusArrivalRepository {
    func fetchArrivalInfoList(pageNo: Int, stationId: String) async throws -> [BusArrivalDTO]
    func fetchSpecificBusArrival(cityCode: String, stationId: String, routeId: String) async throws -> [BusInfoDTO]
}
