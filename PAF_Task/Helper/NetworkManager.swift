//
//  NetworkManager.swift
//  PAF_Task
//
//  Created by Kruti on 18/04/24.
//

import Foundation
import Network

class InternetConnectionManager {
    static let shared = InternetConnectionManager()
    
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "InternetConnectionMonitor")
    
    private(set) var isConnectedToInternet: Bool = false {
        didSet {
            NotificationCenter.default.post(name: .InternetConnectionStatusChanged, object: nil, userInfo: ["isConnected": isConnectedToInternet])
        }
    }
    
    private init() {
        startMonitoring()
    }
    
    private func startMonitoring() {
        monitor.pathUpdateHandler = { [weak self] path in
            self?.isConnectedToInternet = path.status == .satisfied
            print("Internet connection status: \(path.status)")
        }
        
        monitor.start(queue: queue)
    }
    
    deinit {
        monitor.cancel()
    }
}

extension Notification.Name {
    static let InternetConnectionStatusChanged = Notification.Name("InternetConnectionStatusChanged")
}
