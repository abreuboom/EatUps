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
import FBSDKLoginKit

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
        loginButton.addTarget(self, action: #selector(self.loginButtonClicked), for: .touchUpInside)
        
        view.addSubview(loginButton)
    }
    
    @IBAction func loginButtonClicked(_ sender: UIButton) {
        let fbLoginManager = FBSDKLoginManager()
        fbLoginManager.logIn(withReadPermissions: ["public_profile", "email", "user_friends"], from: self) { (result, error) in
            if let error = error {
                print("Failed to login: \(error.localizedDescription)")
                return
            }
            
            guard let accessToken = FBSDKAccessToken.current() else {
                print("Failed to get access token")
                return
            }
            
            let credential = FacebookAuthProvider.credential(withAccessToken: accessToken.tokenString)
            
            // Perform login by calling Firebase APIs
            Auth.auth().signIn(with: credential, completion: { (user, error) in
                if let error = error {
                    print("Login error: \(error.localizedDescription)")
                    let alertController = UIAlertController(title: "Login Error", message: error.localizedDescription, preferredStyle: .alert)
                    let okayAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                    alertController.addAction(okayAction)
                    self.present(alertController, animated: true, completion: nil)
                    
                    return
                }
                else {
                    if let uid = user?.uid {
                        
                        if let name = user?.displayName {
                            self.ref.child("users").child(uid).setValue(["name": name])
                        }
                        if let photoURL = user?.photoURL {
                            self.ref.child("users").child(uid).setValue(["profilePhotoURL": photoURL])
                        }
                    }
                    self.performSegue(withIdentifier: "loginSegue", sender: nil)
                }
            })
            
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
