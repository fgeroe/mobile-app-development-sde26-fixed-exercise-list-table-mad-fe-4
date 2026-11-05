//
//  Country.swift
//  MAD
//
//  Created by Fabian Gerö on 05.11.26.
//


import Foundation

nonisolated struct Country: Decodable {
    var ID: String
    var name: String
    var currency: String
    var capital: String
    var native: String
    var continent: String
    var phone: String
    var createTime: Date
    var updateTime: Date
    var languages: [String]

    private enum RootCodingKeys: String, CodingKey {
        case ID = "name"
        case createTime
        case updateTime
        case fields
    }

    private enum NestedCodingKeys: String, CodingKey {
        case name
        case currency
        case capital
        case native
        case continent
        case phone
        case languages
    }

    private enum StringValueCodingKeys: String, CodingKey {
        case stringValue
    }

    private enum ArrayValueCodingKeys: String, CodingKey {
        case arrayValue
    }

    private enum ArrayValueNestedCodingKeys: String, CodingKey {
        case values
    }
}

nonisolated extension Country {
    init(from decoder: Decoder) throws {
        let rootContainer = try decoder.container(keyedBy: RootCodingKeys.self)
        ID = (try rootContainer.decode(String.self, forKey: .ID) as NSString).lastPathComponent
        createTime = try rootContainer.decode(Date.self, forKey: .createTime)
        updateTime = try rootContainer.decode(Date.self, forKey: .updateTime)

        let fieldsContainer = try rootContainer.nestedContainer(keyedBy: NestedCodingKeys.self, forKey: .fields)

        func decodeString(forKey key: NestedCodingKeys) throws -> String {
            let valueContainer = try fieldsContainer.nestedContainer(keyedBy: StringValueCodingKeys.self, forKey: key)
            return try valueContainer.decode(String.self, forKey: .stringValue)
        }

        name = try decodeString(forKey: .name)
        currency = try decodeString(forKey: .currency)
        capital = try decodeString(forKey: .capital)
        native = try decodeString(forKey: .native)
        continent = try decodeString(forKey: .continent)
        phone = try decodeString(forKey: .phone)

        let arrayContainer = try fieldsContainer
            .nestedContainer(keyedBy: ArrayValueCodingKeys.self, forKey: .languages)
            .nestedContainer(keyedBy: ArrayValueNestedCodingKeys.self, forKey: .arrayValue)

        var decodedLanguages: [String] = []

        if arrayContainer.contains(.values) {
            var valuesContainer = try arrayContainer.nestedUnkeyedContainer(forKey: .values)

            while !valuesContainer.isAtEnd {
                let valueContainer = try valuesContainer.nestedContainer(keyedBy: StringValueCodingKeys.self)
                decodedLanguages.append(try valueContainer.decode(String.self, forKey: .stringValue))
            }
        }

        languages = decodedLanguages
    }
}