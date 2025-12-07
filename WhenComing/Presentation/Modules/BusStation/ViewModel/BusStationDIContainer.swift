//
//  BusStationDIContainer.swift
//  WhenComing
//
//  Created by jh on 12/1/25.
//

import Foundation

final class BusStationDIContainer {

    // MARK: - Dependencies

    private lazy var networkService: NetworkServiceProtocol = {
        NetworkService.shared
    }()

    // MARK: - DataSource

    private lazy var busCityCodeLocalDataSource: BusCityCodeLocalDataSource = {
        DefaultBusCityCodeLocalDataSource()
    }()
    
    private lazy var busStationDataSource: BusStationRemoteDataSource = {
        DefaultBusStationRemoteDataSource(networkService: networkService)
    }()
    
    private lazy var busArrivalRemoteDataSource: BusArrivalRemoteDataSource = {
        DefaultBusArrivalRemoteDataSource(networkService: networkService)
    }()
    
    
    

    // MARK: - Repository

    private lazy var busCityCodeRepository: BusCityCodeRepositoryProtocol = {
        DefaultBusCityCodeRepository(localDataSource: busCityCodeLocalDataSource)
    }()
    
    private lazy var busStationRepository: BusStationRepositoryProtocol = {
        DefaultBusStationRepository(remoteDataSource: busStationDataSource)
    }()
    
    private lazy var busArrivalRepository: BusArrivalRepositoryProtocol = {
        DefaultBusArrivalRepository(remoteDataSource: busArrivalRemoteDataSource)
    }()
    
    
    
    
    // MARK: - UseCases
    
    func makeLoadSaveCityCodeUseCase() -> LoadSavedCityCodeUseCase {
        DefaultLoadSavedCityCodeUseCase(repository: busCityCodeRepository)
    }
    
    func makeGetNearbyStationUseCase() -> GetNearbyStationListUseCase {
        DefaultGetNearbyStationListUseCase(repository: busStationRepository)
    }
    
    func makeGetStationThrghBusUseCase() -> GetStationThrghBusListUseCase {
        DefaultGetStationThrghBusListUseCase(repository: busStationRepository)
    }
    
    func makeGetBusArrivalInfoUseCase() -> GetBusArrivalInfoUseCase {
        DefaultGetBusArrivalInfoUseCase(repository: busArrivalRepository)
    }
    
    
    // MARK: - ViewModel
    
    func makeViewModel() -> BusStationViewModel {
        BusStationViewModel(
            loadSaveCityCodeUseCase: makeLoadSaveCityCodeUseCase(), getNearbyStationListUseCase: makeGetNearbyStationUseCase(),
            getStationThrghBusListUseCase: makeGetStationThrghBusUseCase(), getBusArrivalInfoUseCase: makeGetBusArrivalInfoUseCase(),
                            
        )
    }
    
}
