//
//  BusArrivalRepositoryProtocol.swift
//  WhenComing
//
//  Created by jh on 5/12/25.
//

import Foundation

protocol BusArrivalRepository {
    func fetchSpecificBusArrival(pageNo: Int, cityCode: String, stationId: String, routeId: String) async throws -> [SpecificBusArrivalEntity]
}
