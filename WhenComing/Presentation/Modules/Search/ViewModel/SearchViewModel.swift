//
//  BusStationViewModel.swift
//  WhenComing
//
//  Created by jh on 8/19/25.
//

import Foundation
import RxSwift
import RxCocoa

final class SearchViewModel {
    
    enum SearchItem {
        case route(BusRouteEntity)
        case station(BusStationEntity)
    }

    
    private let disposeBag = DisposeBag()
    
    private let itemsRelay = BehaviorRelay<[SearchItem]>(value: [])
    private let isLoadingRelay = BehaviorRelay<Bool>(value: false)
    private let errorRelay = PublishRelay<Error>()
    private var cityCode: String
    private var currentQuery: String?
    private var pageNum = 1
    private var isLastPage: Bool = false
    
    // MARK: - Input/Output
    struct Input {
        let searchQuery: PublishRelay<String>
    }
    struct Output {
        let isLoading: Driver<Bool>
        let error: Signal<Error>
        let items: Driver<[SearchItem]>
    }
    
    let input: Input
    let output: Output
    
    // MARK: - Dependencies
    private let loadSaveCityCodeUseCase: LoadSavedCityCodeUseCase
    private let searchStationByNameUseCase: SearchStationByNameUseCase
    private let getRouteUseCase: GetBusRouteListUseCase
    // MARK: - Init
    init(
        loadSaveCityCodeUseCase: LoadSavedCityCodeUseCase,
        searchStationByNameUseCase: SearchStationByNameUseCase,
        getRouteUseCase: GetBusRouteListUseCase
    ) {
        self.loadSaveCityCodeUseCase = loadSaveCityCodeUseCase
        self.searchStationByNameUseCase = searchStationByNameUseCase
        self.getRouteUseCase = getRouteUseCase
        
        self.cityCode = String(loadSaveCityCodeUseCase.load() ?? 0)
        print("searchViewModel cityCode:\(cityCode)")
        self.input = Input(
            searchQuery: PublishRelay<String>()
        )
        
        // MARK: - transform
        
        self.output = Output(
            isLoading: isLoadingRelay.asObservable().asDriver(onErrorDriveWith: .empty()),
            error: errorRelay.asSignal(), items: itemsRelay.asObservable().asDriver(onErrorDriveWith: .empty())
        )
        
        bind()
    }
    
    
    
    private func bind() {
        input.searchQuery
            .debounce(.milliseconds(400), scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] query in
                guard let self = self else { return }
                
                currentQuery = query
                pageNum = 1
                isLastPage = true
                
                Task {
                    
                    self.isLoadingRelay.accept(true)
                    defer {
                        self.isLoadingRelay.accept(false)
                    }
                    async let routesTask = self.getRouteUseCase.execute(cityCode: self.cityCode, routeNo: query)
                    async let stationsTask = self.searchStationByNameUseCase.execute(pageNo: 1, cityCode: self.cityCode, stationName: query)

                    do {
                        print("1")
                        // 1) 노선 먼저 받기
                        let routes = (try? await routesTask) ?? []
                        print("2")
                        let routeItems = Array(routes.prefix(20)).map { SearchItem.route($0) }
                        print("routes 결과 : \(routes)")
                        // 2) 정류장 받기
                        let stations = try await stationsTask
                        let stationItems = stations.map { SearchItem.station($0) }
                        print("stationItems 결과 : \(stationItems)")
                        // 3) 한 배열로 합치기: [노선들..., 정류장들...]
                        let allItems = routeItems + stationItems
                        self.itemsRelay.accept(allItems)
                        print("합친 결과 : \(allItems)")
                        self.pageNum += 1
                    } catch {
                        self.errorRelay.accept(error)
                        self.itemsRelay.accept([])
                        print("error:\(error.localizedDescription)")
                    }
                }
            })
            .disposed(by: disposeBag)
    }
    
    
    func loadNextStationsPage() {
        Task {
            
            if let currentQuery, !currentQuery.isEmpty, !isLastPage {
                do {
                    let moreStations = try await searchStationByNameUseCase.execute(pageNo: pageNum, cityCode: cityCode, stationName: currentQuery)
                    
                    // 새로 가져온 정류장들을 SearchItem.station으로 변환
                    let moreItems = moreStations.map { SearchItem.station($0) }
                    
                    // 기존 items + 새 정류장들
                    let currentItems = self.itemsRelay.value
                    let newItems = currentItems + moreItems
                    self.itemsRelay.accept(newItems)
                    
                    if moreItems.isEmpty {
                        isLastPage = true
                    } else {
                        pageNum += 1
                    }
                }
            }
            // stationsRelay에 append
        }
    }
}
