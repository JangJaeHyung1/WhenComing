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
    private lazy var busRouteRemoteDataSource: BusRouteRemoteDataSource = {
        DefaultBusRouteRemoteDataSource(networkService: networkService)
    }()

    // MARK: - Repository

    private lazy var busStationRepository: BusStationRepositoryProtocol = {
        DefaultBusStationRepository(remoteDataSource: busStationRemoteDataSource)
    }()
    private lazy var busCityCodeRepository: BusCityCodeRepositoryProtocol = {
        DefaultBusCityCodeRepository(localDataSource: busCityCodeLocalDataSource)
    }()
    private lazy var busRouteRepository: BusRouteRepositoryProtocol = {
        DefaultBusRouteRepository(remoteDataSource: busRouteRemoteDataSource)
    }()
    
    // MARK: - UseCases
    
    func makeGetbusStationUseCase() -> SearchStationByNameUseCase {
        DefaultSearchStationByNameUseCase(repository: busStationRepository)
    }
    
    func makeLoadSaveCityCodeUseCase() -> LoadSavedCityCodeUseCase {
        DefaultLoadSavedCityCodeUseCase(repository: busCityCodeRepository)
    }

    func makeGetBusRouteUseCase() -> GetBusRouteListUseCase {
        DefaultGetBusRouteListUseCase(repository: busRouteRepository)
    }
    // MARK: - ViewModel
    
    func makeBusStationViewModel() -> SearchViewModel {
        SearchViewModel(loadSaveCityCodeUseCase: makeLoadSaveCityCodeUseCase(),
                        searchStationByNameUseCase: makeGetbusStationUseCase(),
                        getRouteUseCase: makeGetBusRouteUseCase()
        )
    }
    
}
