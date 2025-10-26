//
//  BusStationDIContainer.swift
//  WhenComing
//
//  Created by jh on 8/19/25.
//

import Foundation

final class BusStationDIContainer {

    // MARK: - Dependencies

    private lazy var networkService: NetworkServiceProtocol = {
        NetworkService.shared
    }()

    // MARK: - DataSource

    private lazy var busStationRemoteDataSource: BusStationRemoteDataSource = {
        DefaultBusStationRemoteDataSource(networkService: networkService)
    }()

    // MARK: - Repository

    private lazy var busStationRepository: BusStationRepositoryProtocol = {
        DefaultBusStationRepository(remoteDataSource: busStationRemoteDataSource)
    }()

    // MARK: - UseCases

    func makeGetCityCodeListUseCase() -> GetCityCodeListUseCase {
        DefaultGetCityCodeListUseCase(repository: busStationRepository)
    }

    // MARK: - ViewModel

    func makeBusStationViewModel() -> BusStationViewModel {
        BusStationViewModel(
            getCityCodeListUseCase: makeGetCityCodeListUseCase()
        )
    }

}
