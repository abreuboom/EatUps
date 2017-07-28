//
//  SelectLocationViewController.swift
//  EatUps
//
//  Created by Marissa Bush on 7/11/17.
//  Copyright © 2017 John Abreu. All rights reserved.
//

import UIKit
import ChameleonFramework

class SelectLocationViewController: UIViewController, UITableViewDataSource, UISearchBarDelegate {
    
    var org_id: String!
    
    @IBOutlet var eatupAtView: EatupAtView!
    @IBOutlet weak var eatupAtParent: UIView!
    @IBOutlet weak var locationsTableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var places: [String] = []
    
    //create an array to update as we filter through the locations to eat
    var filteredPlaces: [String] = []
    
    var userCountIndexes: [Int] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        eatupAtView.layer.cornerRadius = eatupAtView.frame.width/5
        eatupAtView.dropShadow()
        eatupAtView.center = eatupAtParent.center
        eatupAtParent.addSubview(eatupAtView)
        
        self.navigationController?.hidesNavigationBarHairline = true
        
        org_id = User.current?.org_id
        
        locationsTableView.dataSource = self
        searchBar.delegate = self
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.locationsTableView.setContentOffset(CGPoint.init(x: 0, y: searchBar.frame.size.height) , animated: true)
        if org_id != "" {
            APIManager.shared.getPlaces(org_id: org_id!, completion: { (success: Bool, data) in
                if success == true {
                    self.places = data
                    self.filteredPlaces = self.places
                    for place in self.places {
                        APIManager.shared.getUsersCount(place: place, completion: { (success: Bool, usersCount) -> () in
                            if success == true {
                                self.userCountIndexes.append(usersCount)
                                self.locationsTableView.reloadData()
                            }
                        })
                    }
                    
                }
                else {
                    print("getPlaces() failed")
                }
            })
            
            
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        filteredPlaces = []
        places = []
        locationsTableView.deselectRow(at: locationsTableView.indexPathForSelectedRow!, animated: true)
        
        let eatupAtViewCopy = EatupAtView()
        eatupAtViewCopy.frame = eatupAtView.frame
        transitionCoordinator?.animate(alongsideTransition: { (context) in
            context.containerView.addSubview(eatupAtViewCopy)
        }, completion: { _ in
            eatupAtViewCopy.removeFromSuperview()
        })
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LocationCell", for: indexPath) as! LocationCell
        let placeString = filteredPlaces[indexPath.row]
        cell.nameLabel.text = String.randomEmoji() + " " + placeString
        cell.usersCountLabel.text = "\(userCountIndexes[indexPath.row]) nearby"
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredPlaces.count
    }
    
    // MARK: TODO: Create eatUp object when place is selected with place(org and location) and current user information
    
    // This method updates filteredData based on the text in the Search Box
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        // When there is no text, filteredData is the same as the original data. For each item, return true if the item should be included and false if the
        filteredPlaces = searchText.isEmpty ? places : places.filter { (item: String) -> Bool in
            // If dataItem matches the searchText, return true to include it
            return item.range(of: searchText, options: .caseInsensitive, range: nil, locale: nil) != nil
        }
        locationsTableView.reloadData()
    }
    
    @IBAction func logout(_ sender: UIBarButtonItem) {
        APIManager.shared.logout()
    }
    
    // Sends local eatUp object to the user feed view controller
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "selectUpeeSegue" {
            let cell = sender as! UITableViewCell
            if let indexPath = locationsTableView.indexPath(for: cell) {
                let place = filteredPlaces[indexPath.row]
                let userFeedViewController = segue.destination as! UserFeedViewController
                userFeedViewController.place = place
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

extension String{
    static func randomEmoji()->String{
        let emojiStart = 0x1F601
        let ascii = emojiStart + Int(arc4random_uniform(UInt32(35)))
        let emoji = UnicodeScalar(ascii)?.description
        return emoji ?? "😍"
    }
}
