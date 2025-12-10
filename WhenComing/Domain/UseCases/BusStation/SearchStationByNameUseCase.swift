//
//  SearchStationByNameUseCase.swift
//  WhenComing
//
//  Created by jh on 8/19/25.
//

import Foundation

// MARK: - Protocol
protocol SearchStationByNameUseCase {
    
    /// 버스 정류장 이름 검색 결과
    /// - Parameters:
    ///   - pageNo: page number
    ///   - cityCode: city code
    ///   - stationName: 버스 정류장 이름
    /// - Returns: 해당 키워드로 검색된 버스 정류소 이름 결과 리스트
    func execute(pageNo: Int, cityCode: String, stationName: String) async throws -> [BusStationEntity]
}

// MARK: - Implementation
final class DefaultSearchStationByNameUseCase: SearchStationByNameUseCase {
    private let repository: BusStationRepositoryProtocol

    init(repository: BusStationRepositoryProtocol) {
        self.repository = repository
    }

    func execute(pageNo: Int, cityCode: String, stationName: String) async throws -> [BusStationEntity] {
        try await repository.fetchStationList(pageNo: pageNo, cityCode: cityCode, stationName: stationName)
    }
}

