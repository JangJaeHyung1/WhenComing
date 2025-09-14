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
    case getStationList(pageNo: Int, cityCode: String, stationName: String)  // 정류소번호 목록조회: 정류장 이름 검색 결과 가져오기
    case getAroundStationList(pageNo: Int, lat: Float, lng: Float) // 좌표기반근접정류소 목록조회: 주변 정류장 뭐뭐 있는지
    case getSttnThrghRouteList(pageNo: Int, cityCode: String, nodeId: String) // 정류소별경유노선 목록조회: 무슨무슨 버스 오는지
    
    // 버스도착정보 busStationInfo
    case getArrivalInfoList(pageNo: Int, stationId: String) // 정류소별 전체 도착 정보: 정류장을 즐겨찾기 할 경우 해당 정류장에 오는 버스들 시간 띄워줄려고했는데 일단 *보류
    case getSpecificBusArrival(pageNo: Int, cityCode: String, stationId: String, routeId: String) // 특정 노선 도착 정보
    
    // busRouteInfo
    case getBusRouteList(pageNo: Int, cityCode: String, routeId: String) // 노선별경유정류소목록 조회: 해당 버스의 경유 노선으로 어디어디 가는지
    
    
    var serviceType: ServiceType {
        switch self {
        case .getCityCodeList, .getStationList, .getAroundStationList, .getSttnThrghRouteList :
            return .busStationInfo // 버스 정류소 정보
        case .getArrivalInfoList, .getSpecificBusArrival:
            return .busArrivalInfo // 버스 도착 정보
        case .getBusRouteList: // 버스 노선 정보
            return .busRouteInfo
        }
    }


    var baseURL: String {
        return NetworkConfig.baseURL(for: serviceType)
    }
    
    var path: String {
        switch self {
        case .getCityCodeList:
            return "/getCtyCodeList"
        case .getStationList:
            return "/getSttnNoList"
        case .getAroundStationList:
            return "/getCrdntPrxmtSttnList"
        case .getSttnThrghRouteList:
            return "/getSttnThrghRouteList"
            
        case .getArrivalInfoList:
            return "/getSttnAcctoArvlPrearngeInfoList"
        case .getSpecificBusArrival:
            return "/getSttnAcctoSpcifyRouteBusArvlPrearngeInfoList"
            
        case .getBusRouteList:
            return "/getRouteAcctoThrghSttnList"
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
                URLQueryItem(name: "cityCode", value: cityCode),
                URLQueryItem(name: "nodeNm", value: stationName),
            ]
        case .getAroundStationList(pageNo: let pageNo, lat: let lat, lng: let lng):
            queryItems += [
                URLQueryItem(name: "pageNo", value: "\(pageNo)"),
                URLQueryItem(name: "numOfRows", value: "10"),
                URLQueryItem(name: "gpsLati", value: "\(lat)"),
                URLQueryItem(name: "gpsLong", value: "\(lng)"),
            ]
        case .getSttnThrghRouteList(pageNo: let pageNo, cityCode: let cityCode, nodeId: let nodeId):
            queryItems += [
                URLQueryItem(name: "pageNo", value: "\(pageNo)"),
                URLQueryItem(name: "numOfRows", value: "10"),
                URLQueryItem(name: "cityCode", value: cityCode),
                URLQueryItem(name: "nodeid", value: "\(nodeId)"),
            ]
        case .getArrivalInfoList(pageNo: let pageNo, stationId: let stationId):
            break // 보류
        case .getSpecificBusArrival(pageNo: let pageNo, cityCode: let cityCode, stationId: let stationId, routeId: let routeId):
            queryItems += [
                URLQueryItem(name: "pageNo", value: "\(pageNo)"),
                URLQueryItem(name: "numOfRows", value: "10"),
                URLQueryItem(name: "cityCode", value: cityCode),
                URLQueryItem(name: "nodeid", value: "\(stationId)"),
                URLQueryItem(name: "routeId", value: "\(routeId)"),
            ]
        case .getBusRouteList(pageNo: let pageNo, cityCode: let cityCode, routeId: let routeId):
            queryItems += [
                URLQueryItem(name: "pageNo", value: "\(pageNo)"),
                URLQueryItem(name: "numOfRows", value: "10"),
                URLQueryItem(name: "cityCode", value: cityCode),
                URLQueryItem(name: "routeId", value: routeId),
            ]
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
