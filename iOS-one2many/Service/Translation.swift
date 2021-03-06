//
//  Translation.swift
//  Many-to-many-call
//
//  Created by usama farooq on 13/06/2021.
//  Copyright © 2021 VDOTOK. All rights reserved.
//

import Foundation
public protocol ObjectTranslator {
    func decodeObject<T: Decodable>(data: Data) throws -> T
    func decodeObjects<T: Decodable>(data: Data) throws -> [T]

    func encodeObject<T: Encodable>(object: T) throws -> Data
    func encodeObjects<T: Encodable>(objects: [T]) throws -> Data
    
}

public extension ObjectTranslator {
    func decodeObject<T: Decodable>(data: Data) throws -> T {
        return try JSONDecoder().decode(T.self, from: data)
    }
    
    func decodeObjects<T: Decodable>(data: Data) throws -> [T] {
        return try JSONDecoder().decode([T].self, from: data)
    }

    func encodeObject<T: Encodable>(object: T) throws -> Data {
        return try JSONEncoder().encode(object)
    }
    
    func encodeObjects<T: Encodable>(objects: [T]) throws -> Data {
        return try JSONEncoder().encode(objects)
    }
}

public struct ObjectTranslation: ObjectTranslator {
    public init() {}
}
