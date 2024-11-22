//
//  TCPManager.swift
//  IOTApp
//
//  Created by Thushantha Fernando on 21/11/2024.
//

import UIKit
import Network

class TCPManager {
    private var connection: NWConnection?
    private let queue = DispatchQueue(label: "com.tcpclient.queue")
    
    // Connection state handler
    var onStateChange: ((NWConnection.State) -> Void)?
    
    // Data received handler
    var onReceive: ((Data) -> Void)?
    
    init(host: String, port: UInt16) {
        let endpoint = NWEndpoint.hostPort(host: NWEndpoint.Host(host), port: NWEndpoint.Port(integerLiteral: port))
        let parameters = NWParameters.tcp
        
        // Create the connection
        connection = NWConnection(to: endpoint, using: parameters)
        
        // Set state update handler
        connection?.stateUpdateHandler = { [weak self] state in
            self?.handleState(state)
        }
        
        // Start the connection
        connection?.start(queue: queue)
    }
    
    private func handleState(_ state: NWConnection.State) {
        DispatchQueue.main.async {
            self.onStateChange?(state)
        }
        
        switch state {
        case .ready:
            // Connection established - start receiving data
            self.receive()
        case .failed(let error):
            print("Connection failed with error: \(error)")
            self.connection?.cancel()
        default:
            break
        }
    }
    
    // Receive data from server
    private func receive() {
        connection?.receive(minimumIncompleteLength: 1, maximumLength: 65536) { [weak self] content, _, isComplete, error in
            if let data = content {
                DispatchQueue.main.async {
                    self?.onReceive?(data)
                }
            }
            
            if let error = error {
                print("Receive error: \(error)")
                return
            }
            
            if !isComplete {
                // Continue receiving data
                self?.receive()
            }
        }
    }
    
    // Send binary data to server
    func send(_ data: Data, completion: ((Error?) -> Void)? = nil) {
        connection?.send(content: data, completion: .contentProcessed { error in
            if let error = error {
                print("Send error: \(error)")
            }
            DispatchQueue.main.async {
                completion?(error)
            }
        })
    }
    
    // Convert string to binary data and send
    func send(_ string: String, completion: ((Error?) -> Void)? = nil) {
        guard let data = string.data(using: .utf8) else {
            completion?(NSError(domain: "TCPClient", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to convert string to data"]))
            return
        }
        send(data, completion: completion)
    }
    
    // Close connection
    func disconnect() {
        connection?.cancel()
        connection = nil
    }
    
    deinit {
        disconnect()
    }
}
