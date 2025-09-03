//
//  BusInfoDTO.swift
//  WhenComing
//
//  Created by jh on 3/18/25.
//

import Foundation

struct BusInfoListResponseDTO: Decodable {
    let response: BusInfoInnerResponse
}

struct BusInfoInnerResponse: Decodable {
    let header: BusInfoHeader
    let body: BusInfoBody
}

struct BusInfoHeader: Decodable {
    let resultCode: String
    let resultMsg: String
}

struct BusInfoBody: Decodable {
    let items: BusInfoItems
    let numOfRows: Int
    let pageNo: Int
    let totalCount: Int
}

struct BusInfoItems: Decodable {
    let item: [BusInfoDTO]
}

struct BusInfoDTO: Decodable {
    let arrPrevStationCount: Int
    let arrTime: Int
    let nodeId: String
    let nodeName: String
    let routeId: String
    let routeNo: String
    let routeType: String
    let vehicleType: String

    private enum CodingKeys: String, CodingKey {
        case arrPrevStationCount = "arrprevstationcnt"
        case arrTime = "arrtime"
        case nodeId = "nodeid"
        case nodeName = "nodenm"
        case routeId = "routeid"
        case routeNo = "routeno"
        case routeType = "routetp"
        case vehicleType = "vehicletp"
    }
}
