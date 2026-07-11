//
//  BusRouteDIContainer.swift
//  WhenComing
//

import Foundation

final class BusRouteDIContainer {
    private lazy var networkService: NetworkServiceProtocol = {
        NetworkService.shared
    }()

    private lazy var busRouteRemoteDataSource: BusRouteRemoteDataSource = {
        DefaultBusRouteRemoteDataSource(networkService: networkService)
    }()

    private lazy var busCityCodeLocalDataSource: BusCityCodeLocalDataSource = {
        DefaultBusCityCodeLocalDataSource()
    }()

    private lazy var busRouteRepository: BusRouteRepositoryProtocol = {
        DefaultBusRouteRepository(remoteDataSource: busRouteRemoteDataSource)
    }()

    private lazy var busCityCodeRepository: BusCityCodeRepositoryProtocol = {
        DefaultBusCityCodeRepository(localDataSource: busCityCodeLocalDataSource)
    }()

    private func makeGetBusRouteInfoListUseCase() -> GetBusRouteInfoListUseCase {
        DefaultGetBusRouteInfoListUseCase(repository: busRouteRepository)
    }

    private func makeLoadSavedCityCodeUseCase() -> LoadSavedCityCodeUseCase {
        DefaultLoadSavedCityCodeUseCase(repository: busCityCodeRepository)
    }

    func makeViewController(
        route: BusRouteEntity,
        isGoToWork: Bool
    ) -> BusRouteViewController {
        let viewModel = BusRouteViewModel(
            route: route,
            loadSavedCityCodeUseCase: makeLoadSavedCityCodeUseCase(),
            getBusRouteInfoListUseCase: makeGetBusRouteInfoListUseCase()
        )
        return BusRouteViewController(
            route: route,
            isGoToWork: isGoToWork,
            viewModel: viewModel
        )
    }
}
