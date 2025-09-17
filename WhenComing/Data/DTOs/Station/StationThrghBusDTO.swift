//
//  StationThrghBusDTO.swift
//  WhenComing
//
//  Created by jh on 9/15/25.
//
import Foundation

// MARK: - Top-level Response DTO

/// API Response for getSttnThrghRouteList
struct StationThrghRouteListResponseDTO: Decodable {
    let response: ResponseDTO

    struct ResponseDTO: Decodable {
        let header: HeaderDTO
        let body: BodyDTO
    }

    struct HeaderDTO: Decodable {
        let resultCode: String
        let resultMsg: String
    }

    struct BodyDTO: Decodable {
        let items: ItemsDTO
        let numOfRows: Int
        let pageNo: Int
        let totalCount: Int
    }

    struct ItemsDTO: Decodable {
        let item: [StationThrghBusDTO]

        private enum CodingKeys: String, CodingKey { case item }

        /// The API may return either a single object or an array for `item`.
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            if let array = try? container.decode([StationThrghBusDTO].self, forKey: .item) {
                self.item = array
            } else if let single = try? container.decode(StationThrghBusDTO.self, forKey: .item) {
                self.item = [single]
            } else {
                self.item = []
            }
        }
    }
}

// MARK: - Item DTO (each through-route)

/// Single route passing through a station
struct StationThrghBusDTO: Decodable {
    let endNodeName: String       // endnodenm
    let routeId: String           // routeid
    let routeNo: String           // routeno (can be Int or String in API)
    let routeType: String         // routetp
    let startNodeName: String     // startnodenm

    private enum CodingKeys: String, CodingKey {
        case endNodeName = "endnodenm"
        case routeId = "routeid"
        case routeNo = "routeno"
        case routeType = "routetp"
        case startNodeName = "startnodenm"
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        endNodeName = try c.decode(String.self, forKey: .endNodeName)
        routeId = try c.decode(String.self, forKey: .routeId)
        // routeno can be an Int (e.g., 2) or a String (e.g., "2(심야)", "5-1", "88(A)")
        if let intVal = try? c.decode(Int.self, forKey: .routeNo) { routeNo = String(intVal) }
        else { routeNo = try c.decode(String.self, forKey: .routeNo) }
        routeType = try c.decode(String.self, forKey: .routeType)
        startNodeName = try c.decode(String.self, forKey: .startNodeName)
    }
}



// MARK: - Mappers (DTO -> Entity)

extension StationThrghBusDTO {
    func toEntity() -> StationThrghBusEntity {
        return StationThrghBusEntity(routeId: routeId,
                                     routeNo: routeNo,
                                     routeType: routeType,
                                     startNodeName: startNodeName,
                                     endNodeName: endNodeName
        )
    }
}
