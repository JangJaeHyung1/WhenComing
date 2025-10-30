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
    private var cityCode: Int
    
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
    
    // MARK: - Init
    init(
        loadSaveCityCodeUseCase: LoadSavedCityCodeUseCase
    ) {
        self.loadSaveCityCodeUseCase = loadSaveCityCodeUseCase
        self.cityCode = loadSaveCityCodeUseCase.load() ?? 0
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
        
    }
    
}
