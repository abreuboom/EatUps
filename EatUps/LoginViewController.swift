//
//  LoginViewController.swift
//  EatUps
//
//  Created by Marissa Bush on 7/11/17.
//  Copyright © 2017 John Abreu. All rights reserved.
//

import UIKit
import FacebookCore
import FacebookLogin

class LoginViewController: UIViewController, LoginButtonDelegate {
    
    var loginButton: LoginButton
    
    @IBOutlet weak var logoImage: UIImageView!
    
    @IBOutlet weak var usernameTextField: UITextField!

    @IBOutlet weak var passwordTextField: UITextField!
    
   
    
    @IBAction func didTapLogin(_ sender: UIButton) {
        
    }
    
    @IBAction func didTapSignup(_ sender: Any) {
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if AccessToken.current == nil {
            print("Not logged in")
        }
        else {
            print("Logged in already")
        }
        
        // Added Facebook login button
        loginButton = LoginButton(readPermissions: [ .publicProfile ])
        loginButton.center = view.center
        view.addSubview(loginButton)
        
        
        // User is logged in, use 'accessToken' here.

        // Do any additional setup after loading the view.
    }
    
    // Initialise user with Facebook information
    func loginButtonDidCompleteLogin(_ loginButton: LoginButton, result: LoginResult) {

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
