//
//  MainDIContainer.swift
//  WhenComing
//
//  Created by jh on 5/25/26.
//

import Foundation

final class MainDIContainer {

    // MARK: - Dependencies

    private lazy var networkService: NetworkServiceProtocol = {
        NetworkService.shared
    }()

    // MARK: - DataSource

    private lazy var favoriteBusLocalDataSource: FavoriteBusLocalDataSource = {
        DefaultFavoriteBusLocalDataSource()
    }()

    private lazy var busArrivalRemoteDataSource: BusArrivalRemoteDataSource = {
        DefaultBusArrivalRemoteDataSource(networkService: networkService)
    }()

    // MARK: - Repository

    private lazy var favoriteBusRepository: FavoriteBusRepositoryProtocol = {
        DefaultFavoriteBusRepository(localDataSource: favoriteBusLocalDataSource)
    }()


    private lazy var busArrivalRepository: BusArrivalRepositoryProtocol = {
        DefaultBusArrivalRepository(remoteDataSource: busArrivalRemoteDataSource)
    }()

    // MARK: - UseCases

    private func makeObserveFavoriteBusListUseCase() -> ObserveFavoriteBusListUseCase {
        DefaultObserveFavoriteBusListUseCase(repo: favoriteBusRepository)
    }

    private func makeGetSpecificBusArrivalUseCase() -> GetSpecificBusArrivalUseCase {
        DefaultSpecificBusArrivalUseCase(repository: busArrivalRepository)
    }

    private func makeToggleFavoriteBusUseCase() -> ToggleFavoriteBusUseCase {
        DefaultToggleFavoriteBusUseCase(repo: favoriteBusRepository)
    }

    // MARK: - ViewModel

    func makeViewModel() -> MainViewModel {
        MainViewModel(
            observeFavoriteBusListUseCase: makeObserveFavoriteBusListUseCase(),
            getSpecificBusArrivalUseCase: makeGetSpecificBusArrivalUseCase(),
            toggleFavoriteBusUseCase: makeToggleFavoriteBusUseCase()
        )
    }
}
