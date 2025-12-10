//
//  GetNearbyStationListUseCase.swift
//  WhenComing
//
//  Created by jh on 9/22/25.
//

import Foundation

// MARK: - Protocol
protocol GetNearbyStationListUseCase {
    
    /// 해당 위치 근처 정류소 리스트 가져오는 메소드
    /// - Parameters:
    ///   - pageNo: page number
    ///   - lat: 위도
    ///   - lng: 경도
    /// - Returns: 정류소 리스트
    func execute(pageNo: Int, lat: Double, lng: Double) async throws -> [AroundBusStationEntity]
}

// MARK: - Implementation
final class DefaultGetNearbyStationListUseCase: GetNearbyStationListUseCase {
    private let repository: BusStationRepositoryProtocol

    init(repository: BusStationRepositoryProtocol) {
        self.repository = repository
    }

    func execute(pageNo: Int, lat: Double, lng: Double) async throws -> [AroundBusStationEntity] {
        try await repository.fetchNearbyStationList(pageNo: pageNo, latitude: lat, longitude: lng)
    }
}

