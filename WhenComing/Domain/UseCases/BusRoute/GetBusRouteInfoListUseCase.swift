//
//  GetBusRouteInfoListUseCase.swift
//  WhenComing
//
//  Created by jh on 9/22/25.
//

import Foundation

// MARK: - Protocol
protocol GetBusRouteInfoListUseCase {
    
    /// 특정 노선(routeId)에 대한 상세 운행 정보 목록을 조회한다.
    /// - Parameters:
    ///   - pageNo: 페이징 번호
    ///   - cityCode: 도시 코드
    ///   - routeId: 버스 노선 ID
    /// - Returns: 해당 노선의 운행 정보
    func execute(pageNo: Int, cityCode: String, routeId: String) async throws -> [BusRouteInfoEntity]
}

// MARK: - Implementation
final class DefaultGetBusRouteInfoListUseCase: GetBusRouteInfoListUseCase {
    private let repository: BusRouteRepositoryProtocol

    init(repository: BusRouteRepositoryProtocol) {
        self.repository = repository
    }

    func execute(pageNo: Int, cityCode: String, routeId: String) async throws -> [BusRouteInfoEntity] {
        try await repository.fetchBusRouteInfo(pageNo: pageNo, cityCode: cityCode, routeId: routeId)
    }
}

