//
//  NetworkService.swift
//  WhenComing
//
//  Created by jh on 2/26/25.
//

import Foundation

protocol NetworkServiceProtocol {
    func request<T: Decodable>(_ endpoint: APIEndpoint, type: T.Type) async throws -> T
}

final class NetworkService: NetworkServiceProtocol {
    static let shared = NetworkService()
    
    private init() {}
    
    func request<T: Decodable>(_ endpoint: APIEndpoint, type: T.Type) async throws -> T {
        guard let request = endpoint.urlRequest else {
            throw APIError.urlError
        }
//        print(request)
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        
        guard httpResponse.statusCode == 200 else {
            throw APIError.serverError(httpResponse.statusCode)
        }
        
        do {
//            print("🟠 Raw JSON:")
//            print(String(data: data, encoding: .utf8) ?? "nil")
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            throw APIError.failToDecode(error.localizedDescription)
        }
    }
}
