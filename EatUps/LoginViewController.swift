//
//  LoginViewController.swift
//  EatUps
//
//  Created by Marissa Bush on 7/11/17.
//  Copyright © 2017 John Abreu. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase
import FacebookLogin
import FacebookCore
import PKHUD
import ChameleonFramework

class LoginViewController: UIViewController {
    
    
    var ref: DatabaseReference!
    var loginOnce = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = GradientColor(gradientStyle: .topToBottom, frame: self.view.frame, colors: [HexColor(hexString: "FE8F72"), HexColor(hexString: "FE3F67")])
        ref = Database.database().reference()
    }
    
    @IBAction func loginButtonClicked(_ sender: LoginButton) {
        APIManager.shared.loginManager.logIn([ .publicProfile, .email, .userFriends ], viewController: self) { loginResult in
            switch loginResult {
            case .failed(let error):
                print(error)
            case .cancelled:
                print("User cancelled login.")
            case .success(let grantedPermissions, let declinedPermissions, let accessToken):
                APIManager.shared.login(completion: { (success) in
                    if success == true {
                        self.loginOnce += 1
                        if self.loginOnce <= 1 {
                            print("Logged in!")
                            if User.current?.org_id == "" {
                                self.performSegue(withIdentifier: "orgSegue", sender: nil)
                            }
                            else {
                                self.performSegue(withIdentifier: "loginSegue", sender: nil)
                            }
                        }
                    }
                })
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        Auth.auth().addStateDidChangeListener { (auth, user) in
            if user != nil {
                if User.current?.id != nil {
                    self.performSegue(withIdentifier: "loginSegue", sender: nil)
                }
            }
        }
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
