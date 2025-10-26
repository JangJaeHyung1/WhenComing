//
//  CityCodeUseCase.swift
//  WhenComing
//
//  Created by jh on 10/26/25.
//

protocol LoadSavedCityCodeUseCase {
    func execute() async -> Int?
}

protocol SaveCityCodeUseCase {
    func execute(_ code: Int) async
}

final class DefaultLoadSavedCityCodeUseCase: LoadSavedCityCodeUseCase {
    private let repo: BusCityCodeRepositoryProtocol
    
    init(repo: BusCityCodeRepositoryProtocol) {
        self.repo = repo
    }
    
    func execute() -> Int? {
        repo.loadCityCode()
    }
}

final class DefaultSaveCityCodeUseCase: SaveCityCodeUseCase {
    private let repo: BusCityCodeRepositoryProtocol
    
    init(repo: BusCityCodeRepositoryProtocol) {
        self.repo = repo
    }
    
    func execute(_ code: Int) {
        repo.saveCityCode(code)
    }
}
