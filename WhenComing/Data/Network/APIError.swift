//
//  APIError.swift
//  WhenComing
//
//  Created by jh on 2/26/25.
//

import Foundation

public enum APIError: Error, LocalizedError {
    case urlError
    case invalidResponse
    case failToDecode(String)
    case dataNil
    case serverError(Int)
    case requestFailed(String)
    
    public var description: String {
        switch self {
        case .urlError:
            return "URL이 올바르지 않습니다"
        case .invalidResponse:
            return "응닶값이 유효하지 않습니다"
        case .failToDecode(let description):
            return "디코딩 에러 \(description)"
        case .dataNil:
            return "데이터가 없습니다"
        case .serverError(let statusCode):
            return "서버에러 \(statusCode)"
        case .requestFailed(let message):
            return "서벼 요청 실패 \(message)"
        }
    }
}
