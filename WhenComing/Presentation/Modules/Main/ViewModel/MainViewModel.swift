//
//  MainViewModel.swift
//  WhenComing
//
//  Created by jh on 5/25/26.
//


import Foundation
import CoreLocation
import RxSwift
import RxCocoa

struct MainFavoriteBusRow {
    let favorite: FavoriteBusEntity
    let arrival: SpecificBusArrivalEntity?
    let isLoadingArrival: Bool
}

struct MainFavoriteBusSection {
    let stationId: String
    let stationName: String
    let distance: CLLocationDistance?
    let rows: [MainFavoriteBusRow]
}

extension Array where Element == MainFavoriteBusSection {
    var itemIds: [[String]] {
        map { section in
            section.rows.map(\.favorite.id)
        }
    }
}

final class MainViewModel {
    struct Input {
        let isGoToWork: BehaviorRelay<Bool>
        let refreshTrigger: PublishRelay<Void>
        let currentLocation: BehaviorRelay<CLLocation?>
    }

    struct Output {
        let sections: Driver<[MainFavoriteBusSection]>
        let isLoading: Driver<Bool>
        let error: Signal<Error>
    }

    let input: Input
    let output: Output

    private let disposeBag = DisposeBag()
    private let rowsRelay = BehaviorRelay<[MainFavoriteBusRow]>(value: [])
    private let sectionsRelay = BehaviorRelay<[MainFavoriteBusSection]>(value: [])
    private let elapsedSecondsRelay = BehaviorRelay<Int>(value: 0)
    private let isLoadingRelay = BehaviorRelay<Bool>(value: false)
    private let errorRelay = PublishRelay<Error>()
    private var fetchTask: Task<Void, Never>?

    private let observeFavoriteBusListUseCase: ObserveFavoriteBusListUseCase
    private let getSpecificBusArrivalUseCase: GetSpecificBusArrivalUseCase
    private let toggleFavoriteBusUseCase: ToggleFavoriteBusUseCase

    init(
        observeFavoriteBusListUseCase: ObserveFavoriteBusListUseCase,
        getSpecificBusArrivalUseCase: GetSpecificBusArrivalUseCase,
        toggleFavoriteBusUseCase: ToggleFavoriteBusUseCase
    ) {
        self.observeFavoriteBusListUseCase = observeFavoriteBusListUseCase
        self.getSpecificBusArrivalUseCase = getSpecificBusArrivalUseCase
        self.toggleFavoriteBusUseCase = toggleFavoriteBusUseCase

        self.input = Input(
            isGoToWork: BehaviorRelay<Bool>(value: true),
            refreshTrigger: PublishRelay<Void>(),
            currentLocation: BehaviorRelay<CLLocation?>(value: nil)
        )

        self.output = Output(
            sections: sectionsRelay.asDriver(),
            isLoading: isLoadingRelay.asDriver(),
            error: errorRelay.asSignal()
        )

        bind()
    }

    private func bind() {
        let favorites = observeFavoriteBusListUseCase.execute()

        Observable
            .combineLatest(favorites, input.isGoToWork)
            .subscribe(onNext: { [weak self] favorites, isGoToWork in
                let filtered = favorites.filter { $0.isGoToWork == isGoToWork }
                self?.fetchRows(favorites: filtered)
            })
            .disposed(by: disposeBag)

        input.refreshTrigger
            .subscribe(onNext: { [weak self] in
                self?.observeFavoriteBusListUseCase.reload()
            })
            .disposed(by: disposeBag)

        Observable
            .combineLatest(rowsRelay, input.currentLocation, elapsedSecondsRelay)
            .map { [weak self] rows, currentLocation, elapsedSeconds in
                self?.makeSections(
                    rows: rows,
                    currentLocation: currentLocation,
                    elapsedSeconds: elapsedSeconds
                ) ?? []
            }
            .bind(to: sectionsRelay)
            .disposed(by: disposeBag)
    }


    private func fetchRows(favorites: [FavoriteBusEntity]) {
        fetchTask?.cancel()
        let previousRows = Dictionary(
            uniqueKeysWithValues: rowsRelay.value.map { ($0.favorite.id, $0) }
        )
        rowsRelay.accept(
            favorites.map { favorite in
                if let previousRow = previousRows[favorite.id] {
                    return previousRow
                }

                MainFavoriteBusRow(
                    favorite: favorite,
                    arrival: nil,
                    isLoadingArrival: true
                )
            }
        )

        fetchTask = Task { [weak self] in
            guard let self else { return }

            await MainActor.run {
                self.isLoadingRelay.accept(true)
            }

            let rows = await withTaskGroup(of: MainFavoriteBusRow.self) { group in
                for favorite in favorites {
                    group.addTask { [getSpecificBusArrivalUseCase] in
                        let arrival = try? await getSpecificBusArrivalUseCase.executeOne(
                            pageNo: 1,
                            cityCode: favorite.cityCode,
                            stationId: favorite.stationId,
                            routeId: favorite.routeId
                        )

                        return MainFavoriteBusRow(
                            favorite: favorite,
                            arrival: arrival,
                            isLoadingArrival: false
                        )
                    }
                }

                var result: [MainFavoriteBusRow] = []
                for await row in group {
                    result.append(row)
                }
                return result
            }

            guard !Task.isCancelled else { return }

            await MainActor.run {
                let elapsedSeconds = self.elapsedSecondsRelay.value
                let mergedRows = rows.map { row in
                    guard row.arrival == nil,
                          let previousRow = previousRows[row.favorite.id],
                          previousRow.arrival != nil else {
                        return row
                    }

                    return self.adjustedRow(
                        previousRow,
                        elapsedSeconds: elapsedSeconds
                    )
                }

                self.elapsedSecondsRelay.accept(0)
                self.rowsRelay.accept(mergedRows)
                self.isLoadingRelay.accept(false)
            }
        }
    }

    private func makeSections(
        rows: [MainFavoriteBusRow],
        currentLocation: CLLocation?,
        elapsedSeconds: Int
    ) -> [MainFavoriteBusSection] {
        Dictionary(grouping: rows, by: { $0.favorite.stationId })
            .map { stationId, rows in
                let first = rows[0].favorite
                let stationLocation = CLLocation(
                    latitude: first.latitude,
                    longitude: first.longitude
                )
                let distance = currentLocation?.distance(from: stationLocation)
                let adjustedRows = rows.map {
                    adjustedRow($0, elapsedSeconds: elapsedSeconds)
                }
                let sortedRows = adjustedRows.sorted {
                    let leftTime = $0.arrival?.arrivalTime ?? Int.max
                    let rightTime = $1.arrival?.arrivalTime ?? Int.max
                    return leftTime == rightTime
                        ? $0.favorite.routeNo < $1.favorite.routeNo
                        : leftTime < rightTime
                }

                return MainFavoriteBusSection(
                    stationId: stationId,
                    stationName: first.stationName,
                    distance: distance,
                    rows: sortedRows
                )
            }
            .sorted {
                let leftDistance = $0.distance ?? Double.greatestFiniteMagnitude
                let rightDistance = $1.distance ?? Double.greatestFiniteMagnitude
                return leftDistance == rightDistance
                    ? $0.stationName < $1.stationName
                    : leftDistance < rightDistance
            }
    }

    private func adjustedRow(
        _ row: MainFavoriteBusRow,
        elapsedSeconds: Int
    ) -> MainFavoriteBusRow {
        guard let arrival = row.arrival else { return row }

        let adjustedArrival = SpecificBusArrivalEntity(
            nodeId: arrival.nodeId,
            nodeName: arrival.nodeName,
            routeId: arrival.routeId,
            routeNo: arrival.routeNo,
            arrivalTime: max(0, arrival.arrivalTime - elapsedSeconds),
            arrivalAtStationCount: arrival.arrivalAtStationCount
        )

        return MainFavoriteBusRow(
            favorite: row.favorite,
            arrival: adjustedArrival,
            isLoadingArrival: row.isLoadingArrival
        )
    }

    func advanceArrivalCountdown() {
        elapsedSecondsRelay.accept(elapsedSecondsRelay.value + 1)
    }

    func reloadFavorites() {
        observeFavoriteBusListUseCase.reload()
    }

    func removeFavorite(_ favorite: FavoriteBusEntity) {
        rowsRelay.accept(
            rowsRelay.value.filter { $0.favorite.id != favorite.id }
        )
        toggleFavoriteBusUseCase.execute(item: favorite)
    }

    deinit {
        fetchTask?.cancel()
    }
}
