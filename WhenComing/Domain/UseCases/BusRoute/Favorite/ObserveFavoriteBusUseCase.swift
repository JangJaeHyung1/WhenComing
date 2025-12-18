//
//  ObserveFavoriteBusUseCase.swift
//  WhenComing
//
//  Created by jh on 12/19/25.
//

import Foundation
import RxSwift
import RxCocoa

// MARK: - Protocol
protocol ObserveFavoriteBusIdSetUseCase {

  /// 즐겨찾기 버스 id Set을 observe
  /// - Returns: 즐겨찾기 id Set (예: "city|station|route")
  func execute() -> Observable<Set<String>>
}

// MARK: - Implementation
final class DefaultObserveFavoriteBusIdSetUseCase: ObserveFavoriteBusIdSetUseCase {
  private let repo: FavoriteBusRepositoryProtocol

  init(repo: FavoriteBusRepositoryProtocol) {
    self.repo = repo
  }

  func execute() -> Observable<Set<String>> {
    repo.observeFavorites()
      .map { Set($0.map(\.id)) }
  }
}
