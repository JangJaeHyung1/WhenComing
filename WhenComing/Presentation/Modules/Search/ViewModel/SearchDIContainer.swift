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
        DefaultBusCityCodeRepository(localDataSource: busCityCodeLocalDataSource)
    }()

    // MARK: - UseCases
    
    func makeGetbusStationUseCase() -> SearchStationByNameUseCase {
        DefaultSearchStationByNameUseCase(repository: busStationRepository)
    }
    
    func makeLoadSaveCityCodeUseCase() -> LoadSavedCityCodeUseCase {
        DefaultLoadSavedCityCodeUseCase(repository: busCityCodeRepository)
    }

    // MARK: - ViewModel
    
    func makeBusStationViewModel() -> SearchViewModel {
        SearchViewModel(loadSaveCityCodeUseCase: makeLoadSaveCityCodeUseCase(),
                        searchStationByNameUseCase: makeGetbusStationUseCase()
        )
    }
    
}
