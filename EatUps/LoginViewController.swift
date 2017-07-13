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
    
    @IBOutlet weak var logoImage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Persisting User
        if AccessToken.current == nil {
            print("Not logged in")
        }
        else {
            print("Logged in already")
        }
        
        // Added Facebook login button
        let loginButton = LoginButton(readPermissions: [ .publicProfile ])
        loginButton.center = view.center
        view.addSubview(loginButton)
        loginButton.delegate = self

        // Do any additional setup after loading the view.
    }
    
    // Initialise user with Facebook information
    func loginButtonDidCompleteLogin(_ loginButton: LoginButton, result: LoginResult) {
        let request = GraphRequest(graphPath: "me", parameters: ["fields": "email, name"], accessToken: AccessToken.current, httpMethod: .GET, apiVersion: .defaultVersion)
        request.start { (response, result) in
            switch result {
            case .success(response: let value):
                print(value.dictionaryValue)
            case.failed(let error):
                print(error)
            }
        }
    }
    
    func loginButtonDidLogOut(_ loginButton: LoginButton) {
        // Do log out
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
