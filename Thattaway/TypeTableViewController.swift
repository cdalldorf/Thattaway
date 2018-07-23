//
//  TypeTableViewController.swift
//  Thattaway
//
//  Created by Chris Dalldorf on 7/23/18.
//  Copyright © 2018 Chris Dalldorf. All rights reserved.
//

import UIKit

var types = ["any", "restaurant", "bar", "cafe", "store", "zoo", "supermarket", "shopping_mall", "school", "pharmacy", "parking", "night_club", "museum", "movie_theater", "spa", "atm", "amusement_park", "convenience_store", "book_store", "clothing_store", "doctor", "electronics_store", "furniture_store", "home_goods_store"]

protocol TypeTableDelegate: class {
    func typeUpdated(type: String)
}

class TypeTableViewController: UITableViewController {
    var mainVC : ViewController?
    
    var delegate : TypeTableDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        // preserve selection between presentations
        self.clearsSelectionOnViewWillAppear = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return types.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)

        // Configure the cell...
        cell.textLabel?.text = types[indexPath.row]
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.typeUpdated(type: types[indexPath.row])
        dismiss(animated: true, completion: nil)
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
