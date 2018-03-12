//
//  LoginVC.swift
//  v2POCFaceID
//
//  Created by Kunal Parekh on 09/03/18.
//  Copyright © 2018 v2soltions. All rights reserved.
//

import UIKit

enum deviceTypeENUM :String{
    case notAvailable
    case faceID
    case touchID
}

class LoginVC: UIViewController {
    
    // MARK: - Properties
    let createLoginButtonTag = 0
    let loginButtonTag = 1
    var touchMe:BiometricIDAuth!
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var createInfoLabel: UILabel!
    @IBOutlet weak var touchIDButton: UIButton!
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.setAuthentication()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(self.setAuthentication), name: NSNotification.Name(rawValue: "checkAuthentication"), object: nil)
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "checkAuthentication"), object: nil)
    }
    
    @objc func setAuthentication() {
        touchMe = BiometricIDAuth()
        touchIDButton.isHidden = !touchMe.canEvaluatePolicy()
        var deviceType = deviceTypeENUM.notAvailable
        
        switch touchMe.biometricType() {
        case .faceID:
            deviceType = .faceID
            touchIDButton.setImage(UIImage(named: "FaceIcon"),  for: .normal)
            createInfoLabel.text = "Use FaceID to login"
        case .none:
            deviceType = .notAvailable
            createInfoLabel.text = "FaceID/TouchID not available in device"
        default:
            deviceType = .touchID
            touchIDButton.setImage(UIImage(named: "Touch-icon-lg"),  for: .normal)
            createInfoLabel.text = "Use TouchID to login"
        }
        
        let touchBool = touchMe.canEvaluatePolicy()
        if touchBool {
            self.touchIDLoginAction()
        }else{
            if deviceType == .faceID{
                createInfoLabel.text = "FaceID may not be configured"
            }
            else if deviceType == .touchID{
                createInfoLabel.text = "TouchID may not be configured"
            }
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    @IBAction func touchIDLoginAction() {
        touchMe.authenticateUser() { [weak self] message in
            if let message = message {
                // if the completion is not nil show an alert
                let alertView = UIAlertController(title: "Error",
                                                  message: message,
                                                  preferredStyle: .alert)
                let okAction = UIAlertAction(title: "Darn!", style: .default)
                alertView.addAction(okAction)
                self?.present(alertView, animated: true)
                
            } else {
                self?.performSegue(withIdentifier: "segueToDetail", sender: self)
            }
        }
    }
}

