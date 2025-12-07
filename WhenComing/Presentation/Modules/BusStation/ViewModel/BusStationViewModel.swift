//
//  BusStationViewModel.swift
//  WhenComing
//
//  Created by jh on 12/1/25.
//


import Foundation
import RxSwift
import RxCocoa

final class BusStationViewModel {
    
    private let disposeBag = DisposeBag()
    private let itemsRelay = BehaviorRelay<[StationThrghBusEntity]>(value: [])
    private let isLoadingRelay = BehaviorRelay<Bool>(value: false)
    private let isFetchMoreRelay = BehaviorRelay<Bool>(value: false)
    private let errorRelay = PublishRelay<Error>()
    private var pageNum = 1
    private var cityCode: String
    private var isLastPage: Bool = false
    
    // MARK: - Input/Output
    struct Input {
//        let searchQuery: PublishRelay<String>
    }
    struct Output {
        let isLoading: Driver<Bool>
        let error: Signal<Error>
        let items: Driver<[StationThrghBusEntity]>
        let isFetchMore: Driver<Bool>
    }
    
    let input: Input
    let output: Output
    
    // MARK: - Dependencies
    private let loadSaveCityCodeUseCase: LoadSavedCityCodeUseCase
    private let getNearbyStationListUseCase: GetNearbyStationListUseCase
    private let getStationThrghBusListUseCase: GetStationThrghBusListUseCase
    private let getBusArrivalInfoUseCase: GetBusArrivalInfoUseCase
    
    
    
    // MARK: - Init
    init(
        loadSaveCityCodeUseCase: LoadSavedCityCodeUseCase,
        getNearbyStationListUseCase: GetNearbyStationListUseCase,
        getStationThrghBusListUseCase: GetStationThrghBusListUseCase,
        getBusArrivalInfoUseCase: GetBusArrivalInfoUseCase
    ) {
        self.loadSaveCityCodeUseCase = loadSaveCityCodeUseCase
        self.getNearbyStationListUseCase = getNearbyStationListUseCase
        self.getStationThrghBusListUseCase = getStationThrghBusListUseCase
        self.getBusArrivalInfoUseCase = getBusArrivalInfoUseCase
        
        
        self.cityCode = String(loadSaveCityCodeUseCase.load() ?? 0)
        print("BusStationViewModel cityCode:\(cityCode)")
        
        self.input = Input()
        
        // MARK: - transform
        
        self.output = Output(
            isLoading: isLoadingRelay.asDriver(),
            error: errorRelay.asSignal(),
            items: itemsRelay.asDriver(),
            isFetchMore: isFetchMoreRelay.asObservable().asDriver(onErrorDriveWith: .empty())
        )
    }
    
    
    
    private func bind() {
       
    }
    
    /*
     주변의 정류장 보여주는건 일단 보류
    func fetchNearbyStationList(lat: Double, lng: Double) async throws {
        let _ = try await getNearbyStationListUseCase.execute(pageNo: 1, lat: lat, lng: lng)
    }
    */
    
    
    func fetchFirstPage(nodeId: String) {
        pageNum = 1
        isLastPage = false
        isLoadingRelay.accept(true)
        itemsRelay.accept([])
        getStationThrghBusList(nodeId: nodeId)
    }
    
    func fetchNextPage(nodeId: String) {
        guard !isLoadingRelay.value, !isLastPage, !isFetchMoreRelay.value else { return }
        pageNum += 1
        isFetchMoreRelay.accept(true)
        getStationThrghBusList(nodeId: nodeId)
    }
    
    private func getStationThrghBusList(nodeId: String) {
        Task { [weak self] in
            guard let self else { return }
            
            defer {
                self.isLoadingRelay.accept(false)
                self.isFetchMoreRelay.accept(false)
            }
            do {
                let items = try await getStationThrghBusListUseCase.execute(pageNo: self.pageNum, cityCode: self.cityCode, nodeId: nodeId)
                
                let currentItems = self.itemsRelay.value
                let newItems = currentItems + items
                self.itemsRelay.accept(newItems)
                
                if items.count < 20 {
                    isLastPage = true
                }
            } catch {
                print("error: \(error.localizedDescription)")
            }
        }
    }
    
    
    func getStationArrivalInfo(stationId: String) {
        Task { [weak self] in
            guard let self else { return }
            
            defer {}
            do {
                let item = try await getBusArrivalInfoUseCase.execute(pageNo: 1, stationId: stationId)
                print("getStationArrivalInfo item:\(item)")
            } catch {
                
            }
        }
    }
    
}
