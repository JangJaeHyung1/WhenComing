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
    
    private let disposeBag = DisposeBag()
    
    private let isLoadingRelay = BehaviorRelay<Bool>(value: false)
    private let errorRelay = PublishRelay<Error>()
    private var cityCode: String
    
    // MARK: - Input/Output
    struct Input {
        let searchQuery: PublishRelay<String>
    }
    struct Output {
        let isLoading: Driver<Bool>
        let error: Signal<Error>
    }
    
    let input: Input
    let output: Output
    
    // MARK: - Dependencies
    private let loadSaveCityCodeUseCase: LoadSavedCityCodeUseCase
    private let searchStationByNameUseCase: SearchStationByNameUseCase
    
    // MARK: - Init
    init(
        loadSaveCityCodeUseCase: LoadSavedCityCodeUseCase,
        searchStationByNameUseCase: SearchStationByNameUseCase
    ) {
        self.loadSaveCityCodeUseCase = loadSaveCityCodeUseCase
        self.searchStationByNameUseCase = searchStationByNameUseCase
        
        self.cityCode = String(loadSaveCityCodeUseCase.load() ?? 0)
        print("searchViewModel cityCode:\(cityCode)")
        self.input = Input(
            searchQuery: PublishRelay<String>()
        )
        
        // MARK: - transform
        
        self.output = Output(
            isLoading: isLoadingRelay.asObservable().asDriver(onErrorDriveWith: .empty()),
            error: errorRelay.asSignal()
        )
        
        bind()
    }
    
    
    
    private func bind() {
        input.searchQuery
            .debounce(.milliseconds(400), scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] query in
                guard let self = self else { return }
                self.isLoadingRelay.accept(true)

                Task {
                    do {
                        let stations = try await self.searchStationByNameUseCase.execute(
                            pageNo: 1,
                            cityCode: self.cityCode,
                            stationName: query
                        )
                        print("search result station: \(stations)")
                        // self?.stationsRelay.accept(stations)
                    } catch {
                        self.errorRelay.accept(error)
                        // self?.stationsRelay.accept([])
                    }

                    self.isLoadingRelay.accept(false)
                }
            })
            .disposed(by: disposeBag)
    }
    
}
