//
//  GetBusRouteListUseCase.swift
//  WhenComing
//
//  Created by jh on 11/15/25.
//

import Foundation

// MARK: - Protocol
protocol GetBusRouteListUseCase {
    
    /// 키워드 검색으로 해당 버스 검색 결과 가져오기
    /// - Parameters:
    ///   - cityCode: city code
    ///   - routeNo: 버스 넘버 e.g. 115
    /// - Returns: 버스 리스트
    func execute(cityCode: String, routeNo: String) async throws -> [BusRouteEntity]
}

// MARK: - Implementation
final class DefaultGetBusRouteListUseCase: GetBusRouteListUseCase {
    private let repository: BusRouteRepositoryProtocol

    init(repository: BusRouteRepositoryProtocol) {
        self.repository = repository
    }

    func execute(cityCode: String, routeNo: String) async throws -> [BusRouteEntity] {
        try await repository.fetchBusRoute(cityCode: cityCode, routeNo: routeNo)
    }
}
