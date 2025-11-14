//
//  BusRouteInfoDTO.swift
//  WhenComing
//
//  Created by jh on 3/18/25.
//

import Foundation

struct BusRouteInfoResponseDTO: Decodable {
    let response: Response

    struct Response: Decodable {
        let header: Header
        let body: Body
    }

    struct Header: Decodable {
        let resultCode: String
        let resultMsg: String
    }

    struct Body: Decodable {
        let items: Items
        let numOfRows: Int
        let pageNo: Int
        let totalCount: Int
    }

    struct Items: Decodable {
        let item: [BusRouteInfoDTO]
    }
}

/// 노선별 경유 정류소 (한 정류소 = 한 개 Stop)
struct BusRouteInfoDTO: Decodable {
    let gpsLati: Double
    let gpsLong: Double
    let nodeId: String
    let nodeNm: String
    let nodeNo: Int
    let nodeOrd: Int
    let routeId: String
    let upDownCd: Int

    private enum CodingKeys: String, CodingKey {
        case gpsLati = "gpslati"
        case gpsLong = "gpslong"
        case nodeId = "nodeid"
        case nodeNm = "nodenm"
        case nodeNo = "nodeno"
        case nodeOrd = "nodeord"
        case routeId = "routeid"
        case upDownCd = "updowncd"
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        self.gpsLati = try c.decodeLossyDouble(forKey: .gpsLati)
        self.gpsLong = try c.decodeLossyDouble(forKey: .gpsLong)
        self.nodeId = try c.decode(String.self, forKey: .nodeId)
        self.nodeNm = try c.decode(String.self, forKey: .nodeNm)
        self.nodeNo = try c.decodeLossyInt(forKey: .nodeNo)
        self.nodeOrd = try c.decodeLossyInt(forKey: .nodeOrd)
        self.routeId = try c.decode(String.self, forKey: .routeId)
        self.upDownCd = try c.decodeLossyInt(forKey: .upDownCd)
    }
}
// MARK: - Lossy decoders (숫자가 문자열로 오는 경우까지 방어)
fileprivate extension KeyedDecodingContainer {
    func decodeLossyInt(forKey key: K) throws -> Int {
        if let v = try? decode(Int.self, forKey: key) { return v }
        if let s = try? decode(String.self, forKey: key) {
            if let v = Int(s.trimmingCharacters(in: .whitespacesAndNewlines)) { return v }
            let digits = s.filter { $0.isNumber || $0 == "-" }
            if !digits.isEmpty, let v = Int(digits) { return v }
        }
        throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: codingPath + [key], debugDescription: "Expected Int or String convertible to Int."))
    }

    func decodeLossyDouble(forKey key: K) throws -> Double {
        if let v = try? decode(Double.self, forKey: key) { return v }
        if let s = try? decode(String.self, forKey: key) {
            if let v = Double(s.trimmingCharacters(in: .whitespacesAndNewlines)) { return v }
            let normalized = s.replacingOccurrences(of: ",", with: "")
            if let v = Double(normalized) { return v }
        }
        throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: codingPath + [key], debugDescription: "Expected Double or String convertible to Double."))
    }
}



extension BusRouteInfoDTO {
    func toEntity() -> BusRouteInfoEntity {
       return BusRouteInfoEntity(lat: gpsLati,
                                 lng: gpsLong,
                                 nodeId: nodeId,
                                 nodeNm: nodeNm,
                                 nodeNo: nodeNo,
                                 nodeOrd: nodeOrd,
                                 routeId: routeId,
                                 upDownCd: upDownCd)
    }
}
