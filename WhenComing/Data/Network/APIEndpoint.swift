//
//  APIEndpoint.swift
//  WhenComing
//
//  Created by jh on 2/26/25.
//

import Foundation

enum APIEndpoint {
    // 버스정류소정보 busArrivalInfo
    case getCityCodeList                    // 서비스 가능 지역 검색
    case getStationList(pageNo: Int, cityCode: String, stationName: String)  // 정류소 목록 검색
    
    // 버스도착정보 busStationInfo
    case getArrivalInfoList(stationId: String)  // 정류소별 전체 도착 정보
    case getSpecificBusArrival(cityCode: String, stationId: String, routeId: String) // 특정 노선 도착 정보
    
    var serviceType: ServiceType {
        switch self {
        case .getCityCodeList, .getStationList :
            return .busStationInfo // 버스 정류소 정보
        case .getArrivalInfoList, .getSpecificBusArrival:
            return .busArrivalInfo // 버스 도착 정보
        }
    }


    var baseURL: String {
        return NetworkConfig.baseURL(for: serviceType)
    }

    var path: String {
        switch self {
        case .getCityCodeList:
            return "/getCtyCodeList"
        case .getStationList(let pageNo, let cityCode, let stationName):
            return "/getSttnNoList"
        case .getArrivalInfoList(let stationId):
            return "/getSttnAcctoArvlPrearngeInfoList"
        case .getSpecificBusArrival(let cityCode, let stationId, let routeId):
            return "/getSttnAcctoSpcifyRouteBusArvlPrearngeInfoList"
        }
    }

    var method: String {
        return "GET"
    }

    var headers: [String: String] {
        ["Content-Type": "application/json"]
    }
    
    var apiKey: String { Bundle.main.object(forInfoDictionaryKey: "API_KEY") as? String ?? "api key not found" }

    var urlRequest: URLRequest? {
        let encodedAPIKey = apiKey.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        
        var components: URLComponents = URLComponents(string: baseURL + path) ?? URLComponents()
        var queryItems: [URLQueryItem] = [
            URLQueryItem(name: "serviceKey", value: encodedAPIKey),
            URLQueryItem(name: "_type", value: "json")
        ]
        switch self {
        case .getCityCodeList:
            break
        case .getStationList(pageNo: let pageNo,cityCode: let cityCode, stationName: let stationName):
            queryItems += [
                URLQueryItem(name: "pageNo", value: "\(pageNo)"),
                URLQueryItem(name: "numOfRows", value: "10"),
                URLQueryItem(name: "_type", value: "json"),
                URLQueryItem(name: "cityCode", value: cityCode),
                URLQueryItem(name: "nodeNm", value: stationName),
            ]
        case .getArrivalInfoList(stationId: let stationId):
            break
        case .getSpecificBusArrival(cityCode: let cityCode, stationId: let stationId, routeId: let routeId):
            break
        }
        
        components.queryItems = queryItems
        components.percentEncodedQuery = components.percentEncodedQuery?
                    .replacingOccurrences(of: "+", with: "%2B")
        guard let url = components.url else { return nil }
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.allHTTPHeaderFields = headers
        return request
        
    }
}
