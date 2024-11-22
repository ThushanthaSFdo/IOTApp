//
//  TCPVC.swift
//  IOTApp
//
//  Created by Thushantha Fernando on 21/11/2024.
//

import UIKit

class TCPVC: UIViewController {
    
    var tcpmanager: TCPManager?
    
    let backButton = UIButton()
    let topicLabel = IATitleLabel(textalignment: .left, fontsize: 36)
    
    deinit {
        tcpmanager?.disconnect()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpViewController()
        configureBackButton()
        configureHeaderLabels()
        setupTCP()
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
        
        topicLabel.text = StringValues.TCP
    }
    
}

extension TCPVC {
    func setupTCP() {
        tcpmanager = TCPManager(host: "telnet https://www.liquidweb.com/", port: 80)
        
        // Handle connection state changes
        tcpmanager?.onStateChange = { state in
            switch state {
            case .ready:
                print("Connected to server")
            case .failed(let error):
                print("Connection failed: \(error)")
            case .waiting(let error):
                print("Waiting: \(error)")
            default:
                print("State: \(state)")
            }
        }
        
        tcpmanager?.onReceive = { data in
            // Handle binary data
            print("Received \(data.count) bytes")
            
            // Example: Convert to string if it's text data
            if let string = String(data: data, encoding: .utf8) {
                print("Received string: \(string)")
            }
            
            // Example: Process binary data
            let bytes = [UInt8](data)
            print("First byte: \(bytes.first ?? 0)")
        }
    }
    
    func sendData() {
        // Send string
        tcpmanager?.send("Hello Server") { error in
            if let error = error {
                print("Failed to send: \(error)")
            }
        }
        
        // Send binary data
        let binaryData = Data([0x01, 0x02, 0x03, 0x04])
        tcpmanager?.send(binaryData) { error in
            if let error = error {
                print("Failed to send binary data: \(error)")
            }
        }
    }
    
    @objc func dismissVC() {
        dismiss(animated: true)
    }
}
