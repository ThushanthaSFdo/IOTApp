//
//  BluetoothManager.swift
//  IOTApp
//
//  Created by Thushantha Fernando on 16/11/2024.
//

import UIKit
import CoreBluetooth

class BluetoothManager: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    
    var centralManager: CBCentralManager!
    var discoveredPeripherals: [CBPeripheral] = []
    var characteristicsInfoList: [String] = []
    
    let deviceNameUUID    = CBUUID(string: "2A00")
    
    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            startScanning()
        } else {
            print("Bluetooth is not available.")
        }
    }
    
    private func startScanning() {
        centralManager.scanForPeripherals(withServices: nil, options: nil)
        NotificationCenter.default.post(name: NSNotification.Name("BluetoothDevicesScanning"), object: nil)
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        
        if !discoveredPeripherals.contains(peripheral) {
            discoveredPeripherals.append(peripheral)
            NotificationCenter.default.post(name: NSNotification.Name("BluetoothDevicesUpdated"), object: nil)
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        NotificationCenter.default.post(name: NSNotification.Name("BluetoothDevicesUpdated"), object: nil)
        
        // Set delegate and discover services
        peripheral.delegate = self
        peripheral.discoverServices(nil)
        
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        if let error = error {
            print("Error disconnection the peripheral: \(error.localizedDescription)")
            return
        }
        
        if let peripheral = peripheral as CBPeripheral?{
            peripheral.delegate = nil
            centralManager.cancelPeripheralConnection(peripheral)
        }
        
        
        NotificationCenter.default.post(name: NSNotification.Name("BluetoothDevicesUpdated"), object: nil)
        
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let error = error {
            print("Error discovering services: \(error.localizedDescription)")
            return
        }
        
        guard let services = peripheral.services else { return }
        
        for service in services {
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if let error = error {
            print("Error discovering characteristics for service \(service.uuid): \(error.localizedDescription)")
            return
        }
        
        guard let characteristics = service.characteristics else { return }
        
        for characteristic in characteristics {
            
            // Read or subscribe to notifications as needed
            if characteristic.properties.contains(.read) {
                peripheral.readValue(for: characteristic)
            }
            
            if characteristic.properties.contains(.notify) {
                peripheral.setNotifyValue(true, for: characteristic)
            }
            
            if !characteristicsInfoList.contains("Discovered characteristic for \(service.uuid): \(characteristic.uuid)") {
                characteristicsInfoList.append("Discovered characteristic for \(service.uuid): \(characteristic.uuid)")
            }
        }
        
        NotificationCenter.default.post(name: NSNotification.Name("DeviceCharacteristicData"), object: nil)
    }
    
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if let error = error {
            print("Error updating value for characteristic: \(error.localizedDescription)")
            return
        }
        
        guard let data = characteristic.value else { return }
        // work with
        
    }
    
    func getDiscoveredPeripherals() -> [CBPeripheral] {
        return discoveredPeripherals
    }
    
    func getCharacteristicData() -> [String] {
        return characteristicsInfoList
    }
}
