//
//  GetBusArrivalInfoUseCase.swift
//  WhenComing
//
//  Created by jh on 12/7/25.
//

import Foundation

// MARK: - Protocol
protocol GetBusArrivalInfoUseCase {
    
    /// 해당 정류소의 버스들의 정보들을 가져오는 메소드
    /// - Parameters:
    ///   - pageNo: page
    ///   - cityCode: city code
    ///   - nodeId: 정류소 ID
    /// - Returns: 버스리스트 도착 시간
    func execute(pageNo: Int, cityCode: String, nodeId: String) async throws -> [BusStationArrivalInfoEntity]
}

// MARK: - Implementation
final class DefaultGetBusArrivalInfoUseCase: GetBusArrivalInfoUseCase {
    private let repository: BusArrivalRepositoryProtocol

    init(repository: BusArrivalRepositoryProtocol) {
        self.repository = repository
    }

    func execute(pageNo: Int, cityCode: String, nodeId: String) async throws -> [BusStationArrivalInfoEntity] {
        try await repository.fetchArrivalInfoList(pageNo: pageNo, cityCode: cityCode, nodeId: nodeId)
    }
}
