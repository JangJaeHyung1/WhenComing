//
//  NetworkConfig.swift
//  WhenComing
//
//  Created by jh on 2/26/25.
//

import Foundation

enum ServiceType {
    case busStationInfo
    case busArrivalInfo
    case busRouteInfo
    case busRoute
}

struct NetworkConfig {
    static func baseURL(for service: ServiceType) -> String {
        switch service {
        case .busStationInfo:
            return APIPath.busSttnInfoInqireService
        case .busArrivalInfo:
            return APIPath.busArvlInfoInqireService
        case .busRouteInfo:
            return APIPath.busRouteInfoInqireService
        case .busRoute:
            return APIPath.busRouteInfoInqireService
        }
    }
}
