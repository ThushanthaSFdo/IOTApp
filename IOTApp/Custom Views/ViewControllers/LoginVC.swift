//
//  LoginVC.swift
//  IOTApp
//
//  Created by Thushantha Fernando on 16/11/2024.
//

import UIKit

class LoginVC: UIViewController {
    
    
    var loggedUser: User!
    
    let bgImageView = IAImageView(frame: .zero)
    let transparentBgView : UIView = {
        let bgView = UIView()
        bgView.translatesAutoresizingMaskIntoConstraints = false
        bgView.backgroundColor = AppColors.mainBgColor.withAlphaComponent(0.7)
        return bgView
    }()
    
    private let usernameTF: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Username"
        textField.borderStyle = .roundedRect
        textField.text = "johnd"
        return textField
    }()
    
    private let passwordTF: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Password"
        textField.isSecureTextEntry = true
        textField.borderStyle = .roundedRect
        textField.text = "abcdef12"
        return textField
    }()
    
    private let rememberMeSwitch: UISwitch = {
        let switchControl = UISwitch()
        switchControl.subviews[0].subviews[0].backgroundColor = AppColors.whiteDocketColor
        return switchControl
    }()
    
    private let rememberMeLabel: UILabel = {
        let label = UILabel()
        label.text = "Remember Me"
        label.textColor = AppColors.whiteDocketColor
        return label
    }()
    
    let loginButton = IAButton(backgroundColor: AppColors.mainBgColor, title: StringValues.Login)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpViewController()
        configureBackdrop()
        configureTransparentView()
        setupLayout()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
        IsUserLoggedIn()
    }
    
    func setUpViewController() {
        view.backgroundColor = AppColors.mainBgColor
    }
    
    func configureBackdrop() {
        view.addSubviews(bgImageView)
        
        NSLayoutConstraint.activate([
            bgImageView.topAnchor.constraint(equalTo: view.topAnchor),
            bgImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bgImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bgImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        
        bgImageView.image = Images.bannerBg
    }
    
    func configureTransparentView() {
        view.insertSubview(transparentBgView, aboveSubview: bgImageView)
        
        NSLayoutConstraint.activate([
            transparentBgView.topAnchor.constraint(equalTo: view.topAnchor),
            transparentBgView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            transparentBgView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            transparentBgView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func setupLayout() {
        // Add subviews
        view.addSubviews(usernameTF,passwordTF,rememberMeSwitch,rememberMeLabel,loginButton)
        
        usernameTF.translatesAutoresizingMaskIntoConstraints = false
        passwordTF.translatesAutoresizingMaskIntoConstraints = false
        rememberMeSwitch.translatesAutoresizingMaskIntoConstraints = false
        rememberMeLabel.translatesAutoresizingMaskIntoConstraints = false
        loginButton.translatesAutoresizingMaskIntoConstraints = false
        
        
        loginButton.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            usernameTF.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            usernameTF.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -75),
            usernameTF.widthAnchor.constraint(equalToConstant: 300),
            
            passwordTF.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            passwordTF.topAnchor.constraint(equalTo: usernameTF.bottomAnchor, constant: 25),
            passwordTF.widthAnchor.constraint(equalToConstant: 300),
            
            rememberMeLabel.topAnchor.constraint(equalTo: passwordTF.bottomAnchor, constant: 25),
            rememberMeLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 50),
            
            rememberMeSwitch.centerYAnchor.constraint(equalTo: rememberMeLabel.centerYAnchor),
            rememberMeSwitch.leadingAnchor.constraint(equalTo: rememberMeLabel.trailingAnchor, constant: 25),
            
            loginButton.topAnchor.constraint(equalTo: rememberMeSwitch.bottomAnchor, constant: 30),
            loginButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loginButton.widthAnchor.constraint(equalToConstant: 200)
        ])
    }
}


extension LoginVC {
    
    @objc private func loginButtonTapped() {
        
        guard let username = usernameTF.text, !username.isEmpty,
              let password = passwordTF.text, !password.isEmpty else {
            showAlert(message: "Please enter both username and password.")
            return
        }
        
        if JSONSimulation.getUserLogin(for: usernameTF.text!, and: passwordTF.text!) {
            getUserInfo()
            
            if rememberMeSwitch.isOn {
                let error = PersistenceManager.saveUser(user: loggedUser)
                
                if error != nil {
                    showAlert(message: "Please log out and reconnect")
                }
            }
            showDashboard(user: loggedUser)
            
        } else {
            showAlert(message: "Either username or password is incorrect")
        }
        
    }
    
    func showDashboard(user: User) {
        let destVC = HomeVC(user: loggedUser)
        let navController = UINavigationController(rootViewController: destVC)
        navController.modalPresentationStyle = .fullScreen
        
        DispatchQueue.main.async { [weak self] in
            self?.present(navController, animated: true)
        }
    }
    
    private func showAlert(message: String) {
        let alertController = UIAlertController(title: "Alert", message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default))
        
        present(alertController, animated: true)
    }
    
    func getUserInfo() {
        JSONSimulation.getUserInfo { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let userinfo):
                self.loggedUser = userinfo
                print(loggedUser.username)
            case .failure(let error):
                showAlert(message: error.rawValue)
            }
        }
    }
    
    private func IsUserLoggedIn(){
        PersistenceManager.retrieveUser { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let user):
                self.loggedUser = user
                showDashboard(user: loggedUser)
            case .failure(_):
                print("Please log in")
            }
        }
    }
}
