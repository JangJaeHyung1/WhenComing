//
//  BusStationDIContainer.swift
//  WhenComing
//
//  Created by jh on 8/19/25.
//

import Foundation

final class SearchDIContainer {

    // MARK: - Dependencies

    private lazy var networkService: NetworkServiceProtocol = {
        NetworkService.shared
    }()

    // MARK: - DataSource

    private lazy var busStationRemoteDataSource: BusStationRemoteDataSource = {
        DefaultBusStationRemoteDataSource(networkService: networkService)
    }()
    private lazy var busCityCodeLocalDataSource: BusCityCodeLocalDataSource = {
        DefaultBusCityCodeLocalDataSource()
    }()

    // MARK: - Repository

    private lazy var busStationRepository: BusStationRepositoryProtocol = {
        DefaultBusStationRepository(remoteDataSource: busStationRemoteDataSource)
    }()
    private lazy var busCityCodeRepository: BusCityCodeRepositoryProtocol = {
        DefaultBusCityCoedRepository(remoteDataSource: busCityCodeLocalDataSource)
    }()

    // MARK: - UseCases
    
    func makeloadSaveCityCodeUseCase() -> LoadSavedCityCodeUseCase {
        DefaultLoadSavedCityCodeUseCase(repository: busCityCodeRepository)
    }

    // MARK: - ViewModel
    
    func makeBusStationViewModel() -> SearchViewModel {
        SearchViewModel(loadSaveCityCodeUseCase: makeloadSaveCityCodeUseCase()
        )
    }
    
}
