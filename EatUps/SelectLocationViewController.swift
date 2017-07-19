//
//  SelectLocationViewController.swift
//  EatUps
//
//  Created by Marissa Bush on 7/11/17.
//  Copyright © 2017 John Abreu. All rights reserved.
//

import UIKit

class SelectLocationViewController: UIViewController, UITableViewDataSource, UISearchBarDelegate {
    
    var org: String?

    @IBOutlet weak var locationsTableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var data: [String] = []
    
    //create an array to update as we filter through the locations to eat
    var filteredData: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        

        APIManager.shared.setUpDatabaseHandle(org_id: org!, completion: { (success: Bool, data) in
            if success == true {
                self.data = data
                self.filteredData = self.data
                self.locationsTableView.reloadData()
            }
            else {
                print("get data failed")
            }
        })
        
        locationsTableView.dataSource = self
        searchBar.delegate = self
        
        print(data)

        // Do any additional setup after loading the view.
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LocationCell", for: indexPath) as! LocationCell
        cell.nameLabel.text = filteredData[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredData.count
    }
    
    // MARK: TODO: Create eatUp object when place is selected with place(org and location) and current user information
    
    // This method updates filteredData based on the text in the Search Box
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        // When there is no text, filteredData is the same as the original data. For each item, return true if the item should be included and false if the
        filteredData = searchText.isEmpty ? data : data.filter { (item: String) -> Bool in
            // If dataItem matches the searchText, return true to include it
            return item.range(of: searchText, options: .caseInsensitive, range: nil, locale: nil) != nil
        }
        locationsTableView.reloadData()
    }
    
    // Sends local eatUp object to the user feed view controller
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "chooseUpee" {
            let locationCell = sender as! LocationCell
            let userFeedViewController = segue.destination as! UserFeedViewController
//            userFeedViewController.locationCell = locationCell
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
