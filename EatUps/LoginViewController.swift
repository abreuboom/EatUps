//
//  LoginViewController.swift
//  EatUps
//
//  Created by Marissa Bush on 7/11/17.
//  Copyright © 2017 John Abreu. All rights reserved.
//

import UIKit
import Firebase
import FacebookLogin

class LoginViewController: UIViewController {
    
    @IBOutlet weak var logoImage: UIImageView!
    
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
        loginButton.addTarget(self, action: #selector(self.loginButtonClicked), for: .touchUpInside)
        
        view.addSubview(loginButton)
    }
    
    @objc func loginButtonClicked() {
        let loginManager = LoginManager()
        loginManager.logIn([ .publicProfile, .email, .userFriends ], viewController: self) { loginResult in
            switch loginResult {
            case .failed(let error):
                print(error)
            case .cancelled:
                print("User cancelled login.")
            case .success(let grantedPermissions, let declinedPermissions, let accessToken):
                print("Logged in!")
            }
        }
    }
    
//    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError?) {
//        if let error = error {
//            print(error.localizedDescription)
//            return
//        }
//        let credential = FacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
//    }
//
//    
//    
//    // Initialise user with Facebook information
//    func loginButtonDidCompleteLogin(_ loginButton: LoginButton, result: LoginResult) {
//        let request = GraphRequest(graphPath: "me", parameters: ["fields": "email, name"], accessToken: AccessToken.current, httpMethod: .GET, apiVersion: .defaultVersion)
//        request.start { (response, result) in
//            switch result {
//            case .success(response: let value):
//                print(value.dictionaryValue)
//            case.failed(let error):
//                print(error)
//            }
//        }
//    }
//    
//    func loginButtonDidLogOut(_ loginButton: LoginButton) {
//        // Do log out
//    }

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
