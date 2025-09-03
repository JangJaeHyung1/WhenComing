//
//  FetchUserUseCase.swift
//  WhenComing
//
//  Created by jh on 2/26/25.
//

import Foundation

//final class FetchUserUseCase {
//    private let userRepository: UserRepository
//
//    init(userRepository: UserRepository) {
//        self.userRepository = userRepository
//    }
//
//    func execute(userId: Int, environment: Environment) async throws -> UserEntity {
//        return try await userRepository.fetchUser(id: userId, environment: environment)
//    }
//}
// 하나의 기능 하나의 usecase로
// 그리고 디렉토리를 서비스(버스, 정류장)별로 묶기
