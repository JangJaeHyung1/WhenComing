//
//  GetSpecificBusArrivalUseCase.swift
//  WhenComing
//
//  Created by jh on 2/26/25.
//

import Foundation

// MARK: - Protocol
protocol GetSpecificBusArrivalUseCase {
    
    /// 해당 정류장에 특정 버스의 도착시간 정보 가져오는 메소드
    /// - Parameters:
    ///   - pageNo: page num
    ///   - cityCode: city code
    ///   - stationId: 정류소 id
    ///   - routeId: 버스 route id
    /// - Returns: 해당 정류소에 가장 도착하는 특정 버스 (단일 객체)
    
    func execute(pageNo: Int, cityCode: String, stationId: String, routeId: String) async throws -> [SpecificBusArrivalEntity]
    func executeOne(pageNo: Int, cityCode: String, stationId: String, routeId: String) async throws -> SpecificBusArrivalEntity?
}

// MARK: - Implementation
final class DefaultSpecificBusArrivalUseCase: GetSpecificBusArrivalUseCase {
    private let repository: BusArrivalRepositoryProtocol

    init(repository: BusArrivalRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute(pageNo: Int, cityCode: String, stationId: String, routeId: String) async throws -> [SpecificBusArrivalEntity] {
        try await repository.fetchSpecificBusArrival(pageNo: pageNo, cityCode: cityCode, stationId: stationId, routeId: routeId)
    }
        
    func executeOne(pageNo: Int, cityCode: String, stationId: String, routeId: String) async throws -> SpecificBusArrivalEntity? {
        let list = try await repository.fetchSpecificBusArrival(pageNo: pageNo, cityCode: cityCode, stationId: stationId, routeId: routeId)
        return list.min(by: { ($0.arrivalTime) < ($1.arrivalTime) })
    }
}

