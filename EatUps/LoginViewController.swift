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

class LoginViewController: UIViewController {
    
    
    var ref: DatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
        
        
        // Add a custom login button to your app
        let loginButton = UIButton(type: .custom)
        loginButton.backgroundColor = UIColor.darkGray
        loginButton.frame = CGRect(x: 0, y: 0, width: 180, height: 40);
        loginButton.center = view.center;
        loginButton.setTitle("Login with Facebook", for: .normal )
        
        // Handle clicks on the button
        loginButton.addTarget(self, action: #selector(self.loginButtonClicked(_:)), for: .touchUpInside)
        
        view.addSubview(loginButton)
    }
    
    @IBAction func loginButtonClicked(_ sender: LoginButton) {
        let loginManager = LoginManager()
        loginManager.logIn([ .publicProfile, .email, .userFriends ], viewController: self) { loginResult in
            switch loginResult {
            case .failed(let error):
                print(error)
            case .cancelled:
                print("User cancelled login.")
            case .success(let grantedPermissions, let declinedPermissions, let accessToken):
                print("Logged in!")
                
                APIManager.shared.login(success: { 
                    self.performSegue(withIdentifier: "orgSegue", sender: nil)
                }, failure: { (error) in
                    print(error?.localizedDescription)
                })
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
