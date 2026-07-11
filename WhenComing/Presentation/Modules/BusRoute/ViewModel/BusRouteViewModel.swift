//
//  BusRouteViewModel.swift
//  WhenComing
//

import Foundation
import RxSwift
import RxCocoa

final class BusRouteViewModel {
    struct Output {
        let stations: Driver<[BusRouteInfoEntity]>
        let isLoading: Driver<Bool>
        let error: Signal<Error>
    }

    let output: Output

    private let stationsRelay = BehaviorRelay<[BusRouteInfoEntity]>(value: [])
    private let isLoadingRelay = BehaviorRelay<Bool>(value: false)
    private let errorRelay = PublishRelay<Error>()

    private let route: BusRouteEntity
    private let cityCode: String
    private let getBusRouteInfoListUseCase: GetBusRouteInfoListUseCase
    private var fetchTask: Task<Void, Never>?
    private let pageSize = 20

    init(
        route: BusRouteEntity,
        loadSavedCityCodeUseCase: LoadSavedCityCodeUseCase,
        getBusRouteInfoListUseCase: GetBusRouteInfoListUseCase
    ) {
        self.route = route
        self.cityCode = String(loadSavedCityCodeUseCase.load() ?? 0)
        self.getBusRouteInfoListUseCase = getBusRouteInfoListUseCase

        self.output = Output(
            stations: stationsRelay.asDriver(),
            isLoading: isLoadingRelay.asDriver(),
            error: errorRelay.asSignal()
        )
    }

    func fetchAllStations() {
        fetchTask?.cancel()
        isLoadingRelay.accept(true)

        fetchTask = Task { [weak self] in
            guard let self else { return }

            var pageNo = 1
            var allStations: [BusRouteInfoEntity] = []
            var stationIds = Set<String>()

            do {
                while !Task.isCancelled {
                    let page = try await self.getBusRouteInfoListUseCase.execute(
                        pageNo: pageNo,
                        cityCode: self.cityCode,
                        routeId: self.route.routeId
                    )

                    let previousCount = allStations.count
                    for station in page {
                        let id = "\(station.upDownCd)|\(station.nodeId)|\(station.nodeOrd)"
                        if stationIds.insert(id).inserted {
                            allStations.append(station)
                        }
                    }

                    if page.count < self.pageSize || allStations.count == previousCount {
                        break
                    }
                    pageNo += 1
                }

                guard !Task.isCancelled else { return }

                let sortedStations = allStations.sorted {
                    if $0.upDownCd == $1.upDownCd {
                        return $0.nodeOrd < $1.nodeOrd
                    }
                    return $0.upDownCd < $1.upDownCd
                }

                await MainActor.run {
                    self.stationsRelay.accept(sortedStations)
                    self.isLoadingRelay.accept(false)
                }
            } catch {
                guard !Task.isCancelled else { return }
                let sortedStations = allStations.sorted {
                    if $0.upDownCd == $1.upDownCd {
                        return $0.nodeOrd < $1.nodeOrd
                    }
                    return $0.upDownCd < $1.upDownCd
                }
                await MainActor.run {
                    if !sortedStations.isEmpty {
                        self.stationsRelay.accept(sortedStations)
                    }
                    self.errorRelay.accept(error)
                    self.isLoadingRelay.accept(false)
                }
            }
        }
    }

    deinit {
        fetchTask?.cancel()
    }
}
