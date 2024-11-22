//
//  NetworkVC.swift
//  IOTApp
//
//  Created by Thushantha Fernando on 17/11/2024.
//

import UIKit
import CoreLocation
import SystemConfiguration.CaptiveNetwork

class NetworkVC: UIViewController {
    
    let backButton = UIButton()
    let topicLabel = IATitleLabel(textalignment: .left, fontsize: 36)
    let connectedTopicLabel = IATitleLabel(textalignment: .left, fontsize: 18)
    let ssidLabel = IATitleLabel(textalignment: .left, fontsize: 14)
    let bssidLabel = IATitleLabel(textalignment: .left, fontsize: 14)
    
    var tableView = UITableView(frame: .zero, style: .plain)
    
    private var networks: [String] = []
    
    var locationManager = CLLocationManager()
    var currentNetworkInfos: Array<NetworkInfo>? {
        get {
            return SSID.fetchNetworkInfo()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpViewController()
        configureBackButton()
        configureHeaderLabels()
        configureTableView()
        configureLabels()
        scanNetworks()
        requestLocationAuthorization()
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
            backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 25),
            backButton.widthAnchor.constraint(equalToConstant: 40),
            backButton.heightAnchor.constraint(equalToConstant: 40),
        ])
    }
    
    func configureHeaderLabels() {
        view.addSubview(topicLabel)
        
        NSLayoutConstraint.activate([
            topicLabel.centerYAnchor.constraint(equalTo: backButton.centerYAnchor),
            topicLabel.leadingAnchor.constraint(equalTo: backButton.trailingAnchor, constant: 15),
            topicLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -25),
            topicLabel.heightAnchor.constraint(equalToConstant: 26)
        ])
        
        topicLabel.text = StringValues.Wifi
    }
    
    func configureTableView() {
        view.addSubview(tableView)
        
        tableView.backgroundColor = .systemBackground
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "WiFiCell")
        tableView.dataSource = self
        tableView.delegate = self
        tableView.showsHorizontalScrollIndicator = false
        tableView.showsVerticalScrollIndicator = false
        tableView.separatorStyle = .none
        tableView.backgroundColor = .clear
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: topicLabel.bottomAnchor, constant: 15),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 25),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -25),
            tableView.heightAnchor.constraint(equalToConstant: 250)
        ])
    }
    
    func configureLabels() {
        view.addSubviews(connectedTopicLabel, ssidLabel, bssidLabel)
        
        NSLayoutConstraint.activate([
            connectedTopicLabel.topAnchor.constraint(equalTo: tableView.bottomAnchor, constant: 20),
            connectedTopicLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 25),
            connectedTopicLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -25),
            connectedTopicLabel.heightAnchor.constraint(equalToConstant: 26),
            
            ssidLabel.topAnchor.constraint(equalTo: connectedTopicLabel.bottomAnchor, constant: 20),
            ssidLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 25),
            ssidLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -25),
            ssidLabel.heightAnchor.constraint(equalToConstant: 26),
            
            bssidLabel.topAnchor.constraint(equalTo: ssidLabel.bottomAnchor, constant: 5),
            bssidLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 25),
            bssidLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -25),
            bssidLabel.heightAnchor.constraint(equalToConstant: 26)
        ])
        
        connectedTopicLabel.text = StringValues.ConnectedLabel
        ssidLabel.text = StringValues.SSIDDefault
        bssidLabel.text = StringValues.BSSIDDefault
    }
    
    func requestLocationAuthorization() {
            if #available(iOS 13.0, *) {
                let status = CLLocationManager().authorizationStatus
                if status == .authorizedWhenInUse {
                    updateWiFi()
                } else {
                    locationManager.delegate = self
                    locationManager.requestWhenInUseAuthorization()
                }
            } else {
                updateWiFi()
            }
        }
    
    func updateWiFi() {
        print("SSID: \(currentNetworkInfos?.first?.ssid ?? "")")
        
        if let ssid = currentNetworkInfos?.first?.ssid {
            ssidLabel.text = "SSID: \(ssid)"
        }
        
        if let bssid = currentNetworkInfos?.first?.bssid {
            bssidLabel.text = "BSSID: \(bssid)"
        }
        
    }
    
    @objc private func scanNetworks() {
        WifiManager.shared.scanWiFiNetworks { [weak self] networks, error in
            guard let self = self else { return }
            
            if let error = error {
                self.showAlert(title: "Error", message: error.localizedDescription)
                return
            }
            
            if let networks = networks {
                self.networks = networks
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    private func promptForPassword(ssid: String) {
        let alert = UIAlertController(
            title: "Connect to \(ssid)",
            message: "Enter password",
            preferredStyle: .alert
        )
        
        alert.addTextField { textField in
            textField.placeholder = "Password"
            textField.isSecureTextEntry = true
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Connect", style: .default) { [weak self] _ in
            guard let password = alert.textFields?.first?.text else { return }
            self?.connectToNetwork(ssid: ssid, password: password)
        })
        
        present(alert, animated: true)
    }
    
    private func connectToNetwork(ssid: String, password: String) {
        WifiManager.shared.connectToNetwork(withSSID: ssid, password: password) { [weak self] error in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                if let error = error {
                    self.showAlert(title: "Connection Failed", message: error.localizedDescription)
                } else {
                    self.showAlert(title: "Success", message: "Connected to \(ssid)")
                }
            }
        }
    }
    
    @objc func dismissVC() {
        dismiss(animated: true)
    }
    
}

extension NetworkVC: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            updateWiFi()
        }
    }

}

extension NetworkVC: UITableViewDataSource, UITableViewDelegate {
    // MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return networks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "WiFiCell", for: indexPath)
        cell.textLabel?.text = networks[indexPath.row]
        cell.backgroundColor = .clear
        cell.textLabel?.textColor = AppColors.lightFontColor
        return cell
    }
    
    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let ssid = networks[indexPath.row]
        promptForPassword(ssid: ssid)
    }
}
