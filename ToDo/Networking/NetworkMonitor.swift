//
//  NetworkMonitor.swift
//  ToDo
//
//  Created by Katerina Dev on 18.02.25.
//

import Network

final class NetworkMonitor {
    
    static let shared = NetworkMonitor()
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue.global(qos: .background)
    
    private var isConnected = false
    
    private init() {
        monitor.pathUpdateHandler = { [weak self] path in
            self?.isConnected = path.status == .satisfied
        }
        monitor.start(queue: queue)
    }
    
    func hasInternetConnection() -> Bool {
        return isConnected
    }
}
