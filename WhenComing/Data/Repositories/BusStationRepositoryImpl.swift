//
//  BusRepository.swift
//  WhenComing
//
//  Created by jh on 2/26/25.
//

import Foundation

final class DefaultBusStationRepository: BusStationRepository {
    private let remoteDataSource: BusStationRemoteDataSource

    init(remoteDataSource: BusStationRemoteDataSource) {
        self.remoteDataSource = remoteDataSource
    }

    func fetchCityCodeList() async throws -> [CityCodeEntity] { // dto 말고 entity로 변환해야함
        try await remoteDataSource.getCityCodeList().map { $0.toEntity() }
    }

    func fetchStationList(pageNo: Int, cityCode: String, stationName: String) async throws -> [BusStationEntity] {
        try await remoteDataSource.getStationList(pageNo: pageNo, cityCode: cityCode, stationName: stationName).map { $0.toEntity() }
    }
}

// 이런식으로 캐시데이터를 가져올지 구분할수잇음
//final class CachingUserRepository: UserRepository {
//    private let remote: RemoteUserDataSource
//    private let local: LocalUserDataSource
//
//    func fetchUser(id: String) async throws -> User {
//        if let cached = try? local.fetchUser(id: id) {
//            return cached.toDomain()
//        }
//
//        let dto = try await remote.fetchUser(id: id)
//        try? local.saveUser(dto: dto)
//        return dto.toDomain()
//    }
//}

// local data source 예시

//final class LocalUserDataSourceImpl: LocalUserDataSource {
//    private var storage: [String: UserDTO] = [:]
//
//    func fetchUser(id: String) throws -> UserDTO? {
//        return storage[id]
//    }
//
//    func saveUser(dto: UserDTO) throws {
//        storage[dto.id] = dto
//    }
//}
