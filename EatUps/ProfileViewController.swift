//
//  ProfileViewController.swift
//  EatUps
//
//  Created by John Abreu on 7/30/17.
//  Copyright © 2017 John Abreu. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var eatups: [EatUp] = []
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidAppear(_ animated: Bool) {
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 300
        APIManager.shared.getUserEatupIds { (success, eatupIds) in
            if success == true {
                APIManager.shared.getEatups(eatupIds: eatupIds, completion: { (success, eatupArray) in
                    if success == true {
                        self.eatups = eatupArray
                        self.tableView.reloadData()
                    }
                })
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        // Do any additional setup after loading the view.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return eatups.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileCell", for: indexPath) as! ProfileCell
            cell.cardView.dropShadow()
            cell.friendsCount.text = "\(APIManager.shared.getUniqueFriends(eatups: eatups, uid: (User.current?.id)!).count)"
            cell.eatupCount.text = "\(eatups.count)"
            return cell
        }
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "EatupCell", for: indexPath) as! EatUpCell
            cell.cardView.dropShadow()
            if eatups.count != 0  {
                cell.eatup = eatups[indexPath.row - 1]
            }
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let cell = sender as! EatUpCell
        let chatVC = segue.destination as! ChatViewController
        chatVC.eatup = cell.eatup
     }
    
}
