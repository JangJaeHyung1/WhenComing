//
//  FetchCityCodeListUseCase.swift
//  WhenComing
//
//  Created by jh on 3/18/25.
//

import Foundation

// MARK: - Protocol
protocol GetCityCodeListUseCase {
    /// 도시 코드 가져오는 메소드
    /// - Returns: 도시 코드 리스트
    func execute() async throws -> [BusCityCodeEntity]
}

// MARK: - Implementation
final class DefaultGetCityCodeListUseCase: GetCityCodeListUseCase {
    private let repository: BusStationRepositoryProtocol

    init(repository: BusStationRepositoryProtocol) {
        self.repository = repository
    }

    func execute() async throws -> [BusCityCodeEntity] {
        try await repository.fetchCityCodeList()
    }
}
