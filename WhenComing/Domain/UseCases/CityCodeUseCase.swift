//
//  CityCodeUseCase.swift
//  WhenComing
//
//  Created by jh on 10/26/25.
//

protocol LoadSavedCityCodeUseCase {
    func load() -> Int?
    func save(_ code: Int)
}

final class DefaultLoadSavedCityCodeUseCase: LoadSavedCityCodeUseCase {
    
    private let repository: BusCityCodeRepositoryProtocol
    
    init(repository: BusCityCodeRepositoryProtocol) {
        self.repository = repository
    }
    
    func load() -> Int? {
        repository.loadCityCode()
    }
    func save(_ code: Int) {
        repository.saveCityCode(code)
    }
}
