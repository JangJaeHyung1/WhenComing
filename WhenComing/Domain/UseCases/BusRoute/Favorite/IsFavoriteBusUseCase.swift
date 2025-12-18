//
//  IsFavoriteBusUseCase.swift
//  WhenComing
//
//  Created by jh on 12/19/25.
//

import Foundation

// MARK: - Protocol
protocol IsFavoriteBusUseCase {

  /// 즐겨찾기 여부 확인
  /// - Parameter id: "city|station|route" 형태의 즐겨찾기 id
  func execute(id: String) -> Bool
}

// MARK: - Implementation
final class DefaultIsFavoriteBusUseCase: IsFavoriteBusUseCase {
  private let repo: FavoriteBusRepositoryProtocol

  init(repo: FavoriteBusRepositoryProtocol) {
    self.repo = repo
  }

  func execute(id: String) -> Bool {
    repo.isFavorite(id: id)
  }
}
