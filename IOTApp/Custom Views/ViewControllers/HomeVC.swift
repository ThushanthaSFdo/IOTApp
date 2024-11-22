//
//  ViewController.swift
//  IOTApp
//
//  Created by Thushantha Fernando on 16/11/2024.
//

import UIKit

class HomeVC: UIViewController{
    
    var user: User!
    
    let avatarImageView = IAAvatarImageView(frame: .zero)
    let topicLabel = IATitleLabel(textalignment: .left, fontsize: 32)
    
    let bluetoothButton = IAImageButton(backgroundColor: AppColors.whiteDocketColor, image: Images.bluetoothIcon, color: AppColors.whiteFontColor, imageSize: 36)
    let bluetoothLabel = IATitleLabel(textalignment: .center, fontsize: 10)
    var bluetoothStackView = UIStackView(frame: .zero)
    
    let wifiButton = IAImageButton(backgroundColor: AppColors.whiteDocketColor, image: Images.wifiIcon, color: AppColors.whiteFontColor, imageSize: 36)
    let wifiLabel = IATitleLabel(textalignment: .center, fontsize: 10)
    var wifiStackView = UIStackView(frame: .zero)
    
    let TCPButton = IAImageButton(backgroundColor: AppColors.whiteDocketColor, image: Images.tcpIcon, color: AppColors.whiteFontColor, imageSize: 36)
    let TCPLabel = IATitleLabel(textalignment: .center, fontsize: 10)
    var TCPStackView = UIStackView(frame: .zero)
    
    var buttonStackView = UIStackView(frame: .zero)
    
    let logoutButton = IAButton(backgroundColor: AppColors.mainBgColor, title: StringValues.Logout)
    
    init(user: User) {
        super.init(nibName: nil, bundle: nil)
        self.user = user
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpViewController()
        configureHeaderLabels()
        downloadAvatarImage()
        configureButtonStack()
        configureLogoutBtn()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        avatarImageView.layer.cornerRadius = avatarImageView.frame.height/2
    }
    
    func setUpViewController() {
        view.backgroundColor = AppColors.mainBgColor
    }
    
    func configureHeaderLabels() {
        view.addSubviews(topicLabel,avatarImageView)
        
        NSLayoutConstraint.activate([
            avatarImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 50),
            avatarImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -25),
            avatarImageView.widthAnchor.constraint(equalToConstant: 64),
            avatarImageView.heightAnchor.constraint(equalToConstant: 64),
            
            topicLabel.centerYAnchor.constraint(equalTo: avatarImageView.centerYAnchor),
            topicLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 25),
            topicLabel.trailingAnchor.constraint(equalTo: avatarImageView.leadingAnchor, constant: -10),
            topicLabel.heightAnchor.constraint(equalToConstant: 26)
            
        ])
        
        topicLabel.text = StringValues.Dashboard
    }
    
    func configureButtonStack() {
        configureBluetoothVerticalStack()
        configureWifiVerticalStack()
        configureTCPVerticalStack()
        
        buttonStackView = UIStackView(arrangedSubviews: [bluetoothStackView, wifiStackView, TCPStackView])
        
        buttonStackView.axis = .horizontal
        buttonStackView.distribution = .fillEqually
        buttonStackView.spacing = 25
        buttonStackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(buttonStackView)
        
        NSLayoutConstraint.activate([
            buttonStackView.topAnchor.constraint(equalTo: topicLabel.bottomAnchor, constant: 200),
            buttonStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            buttonStackView.widthAnchor.constraint(equalToConstant: 350),
            buttonStackView.heightAnchor.constraint(equalToConstant: 100)
        ])
    }
    
    func configureBluetoothVerticalStack() {
        bluetoothStackView.addArrangedSubview(bluetoothButton)
        bluetoothStackView.addArrangedSubview(bluetoothLabel)
        bluetoothStackView.axis = .vertical
        bluetoothStackView.spacing = 10
        
        bluetoothLabel.text = StringValues.Bluetooth
        
        bluetoothButton.addTarget(self, action: #selector(showBluetoothView), for: .touchUpInside)
    }
    
    func configureWifiVerticalStack() {
        wifiStackView.addArrangedSubview(wifiButton)
        wifiStackView.addArrangedSubview(wifiLabel)
        wifiStackView.axis = .vertical
        wifiStackView.spacing = 10
        
        wifiLabel.text = StringValues.Wifi
        
        wifiButton.addTarget(self, action: #selector(showWifiView), for: .touchUpInside)
    }
    
    func configureTCPVerticalStack() {
        TCPStackView.addArrangedSubview(TCPButton)
        TCPStackView.addArrangedSubview(TCPLabel)
        TCPStackView.axis = .vertical
        TCPStackView.spacing = 10
        
        TCPLabel.text = StringValues.TCP
        
        TCPButton.addTarget(self, action: #selector(showTCPView), for: .touchUpInside)
    }
    
    func configureLogoutBtn() {
        view.addSubview(logoutButton)
        logoutButton.translatesAutoresizingMaskIntoConstraints = false
        
        logoutButton.backgroundColor = .clear
        logoutButton.tintColor = AppColors.whiteFontColor
        logoutButton.setTitle(StringValues.Logout, for: .normal)
        logoutButton.layer.cornerRadius = 15
        logoutButton.layer.masksToBounds = true
        logoutButton.layer.borderColor = AppColors.whiteFontColor.cgColor
        logoutButton.layer.borderWidth = 1
        
        NSLayoutConstraint.activate([
            logoutButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            logoutButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoutButton.widthAnchor.constraint(equalToConstant: 190),
            logoutButton.heightAnchor.constraint(equalToConstant: 65)
        ])
        
        logoutButton.addTarget(self, action: #selector(logout), for: .touchUpInside)
    }
    
    
}

extension HomeVC {
    func downloadAvatarImage() {
        guard let image = user.avatar else {
            return
        }
        
        NetworkManager.shared.downloadImage(from: image) { [weak self] Image in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.avatarImageView.image = Image
            }
        }
    }
    
    @objc func showWifiView() {
        let navController = UINavigationController(rootViewController: NetworkVC())
        navController.modalPresentationStyle = .fullScreen
        present(navController, animated: true)
    }
    
    @objc func showBluetoothView() {
        let navController = UINavigationController(rootViewController: BleVC())
        navController.modalPresentationStyle = .fullScreen
        present(navController, animated: true)
    }
    
    @objc func showTCPView() {
        let navController = UINavigationController(rootViewController: TCPVC())
        navController.modalPresentationStyle = .fullScreen
        present(navController, animated: true)
    }
    
    @objc func logout() {
        let error = PersistenceManager.removeUser()
        dismiss(animated: true)
    }
}

