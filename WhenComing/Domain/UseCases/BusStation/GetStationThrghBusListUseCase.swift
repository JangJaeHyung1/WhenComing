//
//  GetStationThrghBusList.swift
//  WhenComing
//
//  Created by jh on 3/18/25.
//

import Foundation

// MARK: - Protocol
protocol GetStationThrghBusListUseCase {
    
    /// 정류소별 경유 노선 목록 조회
    /// - Parameters:
    ///   - pageNo: page num
    ///   - cityCode: city code
    ///   - nodeId: 버스 노선
    /// - Returns: 경유 노선 버스정류장 리스트
    func execute(pageNo: Int, cityCode: String, nodeId: String) async throws -> [StationThrghBusEntity]
}

// MARK: - Implementation
final class DefaultGetStationThrghBusListUseCase: GetStationThrghBusListUseCase {
    private let repository: BusStationRepositoryProtocol

    init(repository: BusStationRepositoryProtocol) {
        self.repository = repository
    }

    func execute(pageNo: Int, cityCode: String, nodeId: String) async throws -> [StationThrghBusEntity] {
        try await repository.fetchStationThrghBusList(pageNo: pageNo, cityCode: cityCode, nodeId: nodeId)
    }
}
