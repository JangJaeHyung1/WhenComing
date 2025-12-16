//
//  BusRouteDTO.swift
//  WhenComing
//
//  Created by jh on 11/8/25.
//

import Foundation

struct BusRouteListResponseDTO: Decodable {
    let response: BusRouteResponse
}

struct BusRouteResponse: Decodable {
    let header: BusRouteHeader
    let body: BusRouteBody
}

struct BusRouteHeader: Decodable {
    let resultCode: String
    let resultMsg: String
}

struct BusRouteBody: Decodable {
    let items: BusRouteItems
    let numOfRows: Int
    let pageNo: Int
    let totalCount: Int
}

struct BusRouteItems: Decodable {
    let item: [BusRouteDTO]

    private enum CodingKeys: String, CodingKey {
        case item
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        
        if let list = try? container.decode([BusRouteDTO].self, forKey: .item) {
            self.item = list
        } else if let single = try? container.decode(BusRouteDTO.self, forKey: .item) {
            self.item = [single]
        } else {
            self.item = []
        }
    }
}

struct BusRouteDTO: Decodable {
    let routeId: String
    let routeNo: String
    let routeType: String
    let startNodeName: String
    let endNodeName: String
    let startVehicleTime: String
    let endVehicleTime: String

    private enum CodingKeys: String, CodingKey {
        case routeId = "routeid"
        case routeNo = "routeno"
        case routeType = "routetp"
        case startNodeName = "startnodenm"
        case endNodeName = "endnodenm"
        case startVehicleTime = "startvehicletime"
        case endVehicleTime = "endvehicletime"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        routeId = try container.decode(String.self, forKey: .routeId)
        routeNo = try container.decodeStringOrInt(forKey: .routeNo)
        routeType = try container.decode(String.self, forKey: .routeType)
        startNodeName = try container.decode(String.self, forKey: .startNodeName)
        endNodeName = try container.decode(String.self, forKey: .endNodeName)
        startVehicleTime = try container.decodeStringOrInt(forKey: .startVehicleTime)
        endVehicleTime = try container.decodeStringOrInt(forKey: .endVehicleTime)
    }
}

private extension KeyedDecodingContainer {
    func decodeStringOrInt(forKey key: Key) throws -> String {
        if let stringValue = try? decode(String.self, forKey: key) {
            return stringValue
        }
        if let intValue = try? decode(Int.self, forKey: key) {
            return String(intValue)
        }
        throw DecodingError.typeMismatch(
            String.self,
            DecodingError.Context(
                codingPath: codingPath + [key],
                debugDescription: "Expected String or Int for key \(key.stringValue)"
            )
        )
    }
}

extension BusRouteDTO {
    func toEntity() -> BusRouteEntity {
       return BusRouteEntity(routeId: routeId, routeNo: routeNo, routeType: routeType, startNodeName: startNodeName, endNodeName: endNodeName, startVehicleTime: startVehicleTime, endVehicleTime: endVehicleTime)
    }
}
