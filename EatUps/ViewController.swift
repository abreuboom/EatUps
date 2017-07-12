//
//  ViewController.swift
//  EatUps
//
//  Created by John Abreu on 7/11/17.
//  Copyright © 2017 John Abreu. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let id = NSUUID.init(uuidString: "John Abreu")
        print(id)
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

