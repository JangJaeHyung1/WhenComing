//
//  ToggleFavoriteBusUseCase.swift
//  WhenComing
//
//  Created by jh on 12/19/25.
//

import Foundation

// MARK: - Protocol
protocol ToggleFavoriteBusUseCase {

  /// 즐겨찾기 토글
  /// - Parameters:
  ///   - item: 즐겨찾기 버스 엔티티
  func execute(item: FavoriteBusEnitity)
}

// MARK: - Implementation
final class DefaultToggleFavoriteBusUseCase: ToggleFavoriteBusUseCase {
  private let repo: FavoriteBusRepositoryProtocol

  init(repo: FavoriteBusRepositoryProtocol) {
    self.repo = repo
  }

  func execute(item: FavoriteBusEnitity) {
    repo.toggle(item)
  }
}
