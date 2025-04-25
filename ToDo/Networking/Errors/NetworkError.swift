//
//  NetworkError.swift
//  ToDo
//
//  Created by Katerina Dev on 6.02.25.
//

import Foundation

enum NetworkError: Error {
    case invalidURL
    case invalidResponse
    case decodingFailed
    case noInternetConnection
}
