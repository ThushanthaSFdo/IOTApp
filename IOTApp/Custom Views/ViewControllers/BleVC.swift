//
//  BleVC.swift
//  IOTApp
//
//  Created by Thushantha Fernando on 17/11/2024.
//

import UIKit
import CoreBluetooth

class BleVC: UIViewController {
    var bluetoothManager: BluetoothManager!
    
    var peripherals: [CBPeripheral] = []
    var characterInfoList: [String] = []
    
    
    var tableView = UITableView(frame: .zero, style: .plain)
    
    private var centralManager: CBCentralManager!
    
    let backButton = UIButton()
    let topicLabel = IATitleLabel(textalignment: .left, fontsize: 36)
    let subTopicLabel = IATitleLabel(textalignment: .left, fontsize: 24)
    let scanLabel = IATitleLabel(textalignment: .right, fontsize: 14)
    let descTopicLabel = IATitleLabel(textalignment: .left, fontsize: 18)
    let descLabel = IABodyLabel(textalignment: .left)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpViewController()
        subscribeNotificationService()
        configureBackButton()
        configureHeaderLabels()
        configureSubLabel()
        configureTableView()
        configureCharacterListArea()
        
        bluetoothManager = BluetoothManager()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    func setUpViewController() {
        view.backgroundColor = AppColors.mainBgColor
    }
    
    func configureBackButton() {
        view.addSubview(backButton)
        
        backButton.backgroundColor = .clear
        backButton.tintColor = .white
        backButton.addTarget(self, action: #selector(dismissVC), for: .touchUpInside)
        backButton.setImage(Images.backButton, for: .normal)
        backButton.layer.cornerRadius = 7
        backButton.layer.masksToBounds = true
        
        backButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 25),
            backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15),
            backButton.widthAnchor.constraint(equalToConstant: 40),
            backButton.heightAnchor.constraint(equalToConstant: 40),
        ])
    }
    
    func configureHeaderLabels() {
        view.addSubview(topicLabel)
        
        NSLayoutConstraint.activate([
            topicLabel.centerYAnchor.constraint(equalTo: backButton.centerYAnchor),
            topicLabel.leadingAnchor.constraint(equalTo: backButton.trailingAnchor, constant: 25),
            topicLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -25),
            topicLabel.heightAnchor.constraint(equalToConstant: 26)
        ])
        
        topicLabel.text = StringValues.Bluetooth
    }
    
    func configureSubLabel() {
        view.addSubviews(subTopicLabel, scanLabel)
        
        NSLayoutConstraint.activate([
            subTopicLabel.topAnchor.constraint(equalTo: backButton.bottomAnchor, constant: 25),
            subTopicLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 25),
            subTopicLabel.widthAnchor.constraint(equalToConstant: 250),
            subTopicLabel.heightAnchor.constraint(equalToConstant: 26),
            
            scanLabel.centerYAnchor.constraint(equalTo: subTopicLabel.centerYAnchor),
            scanLabel.leadingAnchor.constraint(equalTo: subTopicLabel.trailingAnchor, constant: 15),
            scanLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -25),
            scanLabel.heightAnchor.constraint(equalToConstant: 26)
        ])
        
        subTopicLabel.text = StringValues.DeviceList
        scanLabel.text = ""
    }
    
    func configureTableView() {
        view.addSubview(tableView)
        
        tableView.backgroundColor = .systemBackground
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cellID")
        tableView.dataSource = self
        tableView.delegate = self
        tableView.showsHorizontalScrollIndicator = false
        tableView.showsVerticalScrollIndicator = false
        tableView.separatorStyle = .none
        tableView.backgroundColor = .clear
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: subTopicLabel.bottomAnchor, constant: 15),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 25),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -25),
            tableView.heightAnchor.constraint(equalToConstant: 250)
        ])
    }
    
    func configureCharacterListArea() {
        view.addSubviews(descTopicLabel, descLabel)
        
        NSLayoutConstraint.activate([
            descTopicLabel.topAnchor.constraint(equalTo: tableView.bottomAnchor, constant: 25),
            descTopicLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 25),
            descTopicLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -25),
            descTopicLabel.heightAnchor.constraint(equalToConstant: 26),
            
            descLabel.topAnchor.constraint(equalTo: descTopicLabel.bottomAnchor, constant: 25),
            descLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 25),
            descLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -25),
            descLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -25)
        ])
        
        descTopicLabel.text = StringValues.ServiceList
        descLabel.text = "-NA-"
        
        descLabel.numberOfLines = 0
    }
    
}

extension BleVC {
    
    func subscribeNotificationService() {        
        NotificationCenter.default.addObserver(self, selector: #selector(updateDeviceList), name: NSNotification.Name("BluetoothDevicesUpdated"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateCharacList), name: NSNotification.Name("DeviceCharacteristicData"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateScanningStatus), name: NSNotification.Name("BluetoothDevicesScanning"), object: nil)
    }
    
    @objc func updateScanningStatus() {
        scanLabel.text = StringValues.Scanning
    }
    
    func stopScanningStatus() {
        scanLabel.text = ""
    }
    
    @objc func updateDeviceList() {
        // Get updated peripherals from Bluetooth Manager
        peripherals = bluetoothManager.getDiscoveredPeripherals()
        tableView.reloadData() // Refresh the table view with new data
    }
    
    @objc func updateCharacList() {
        // Get updated peripherals from Bluetooth Manager
        var texts = ""
        characterInfoList = bluetoothManager.getCharacteristicData()
        
        for info in characterInfoList {
            texts.append(info + "\n\n")
        }
        
        descLabel.text = texts
    }
    
    @objc func dismissVC() {
        dismiss(animated: true)
    }
     
    func getState(rawValue: Int) -> String{
        switch rawValue {
        case 0:
            return "Not Connected"
        case 1:
            return "Connecting..."
        case 2:
            return "Connected"
        default:
            return "Not Connected"
        }
    }
    
    func requestCancelConnection() {
        for peripheral in peripherals {
            bluetoothManager.centralManager.cancelPeripheralConnection(peripheral)
        }
        
        descLabel.text = "-NA-"
        characterInfoList = []
        
    }
}


extension BleVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return peripherals.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellID", for: indexPath)
        
        let peripheral = peripherals[indexPath.row]
        cell.textLabel?.text = "\(peripheral.name ?? "Unknown Device") (\(getState(rawValue: peripheral.state.rawValue)))"
        
        cell.backgroundColor = .clear
        cell.textLabel?.textColor = AppColors.lightFontColor
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedPeripheral = peripherals[indexPath.row]
        
        bluetoothManager.centralManager.stopScan()
        stopScanningStatus()
        requestCancelConnection()
        bluetoothManager.centralManager.connect(selectedPeripheral, options: nil)
        
        print("#########")
        print("Selected Peripheral \(selectedPeripheral.name ?? "Unknown")")
        print("Connecting to \(selectedPeripheral.identifier)...")
    }
}
