//
//  FirestoreResponseError.swift
//  MAD
//
//  Created by Fabian Gerö on 05.11.26.
//


import Foundation

nonisolated struct FirestoreResponseError: Decodable {
    let error: ErrorDetails

    struct ErrorDetails: Decodable {
        let code: Int
        let message: String
        let status: String
    }
}