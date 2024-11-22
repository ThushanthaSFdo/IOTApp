//
//  WifiManager.swift
//  IOTApp
//
//  Created by Thushantha Fernando on 19/11/2024.
//

import Foundation
import NetworkExtension
import SystemConfiguration.CaptiveNetwork

class WifiManager: NSObject {
    static let shared = WifiManager()
    private var hotspotConfig: NEHotspotConfiguration?
    
    // MARK: - WiFi Scanning
    func scanWiFiNetworks(completion: @escaping ([String]?, Error?) -> Void) {
        guard let interfaces = CNCopySupportedInterfaces() as? [String] else {
            completion(nil, NSError(domain: "WiFiManager", code: 1, userInfo: [NSLocalizedDescriptionKey: "No interfaces available"]))
            return
        }
        
        var networks: [String] = []
        
        for interface in interfaces {
            if let networkInfo = CNCopyCurrentNetworkInfo(interface as CFString) as NSDictionary? {
                if let ssid = networkInfo[kCNNetworkInfoKeySSID as String] as? String {
                    networks.append(ssid)
                }
            }
        }
        
        completion(networks, nil)
    }
    
    // MARK: - WiFi Connection
    func connectToNetwork(withSSID ssid: String, password: String, completion: @escaping (Error?) -> Void) {
        hotspotConfig = NEHotspotConfiguration(ssid: ssid, passphrase: password, isWEP: false)
        
        NEHotspotConfigurationManager.shared.apply(hotspotConfig!) { error in
            if let error = error {
                completion(error)
                return
            }
            completion(nil)
        }
    }
    
    // MARK: - Remove Network Configuration
    func removeNetwork(withSSID ssid: String) {
        NEHotspotConfigurationManager.shared.removeConfiguration(forSSID: ssid)
    }
}
