//
//  FavoritesTableViewController.swift
//  Thattaway
//
//  Created by Chris Dalldorf on 8/17/18.
//  Copyright © 2018 Chris Dalldorf. All rights reserved.
//

import UIKit

protocol FavoritesTableDelegate: class {
    func favoriteSelected(selection: String)
    func favoritesEmpty()
    func favoritesUpdated(favorites: [String], newFav: String)
}

class FavoritesTableViewController: UITableViewController {
    var delegate : FavoritesTableDelegate?
    var options: [String]?
    
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
        return options!.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        // Configure the cell...
        cell.textLabel?.text = options?[indexPath.row]
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (options![indexPath.row] == "create new") {
            let alert = UIAlertController(title: "Pick a name for the new favorite", message: "", preferredStyle: .alert)
            alert.addTextField { (textField) in
                textField.text = ""
            }
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
                let textField = alert?.textFields![0] // Force unwrapping because we know it exists.
                if !(self.options?.contains((textField?.text)!))! && ((textField?.text?.count)! != 0) {
                    self.options?.append((textField?.text)!)
                    self.delegate?.favoritesUpdated(favorites: self.options!, newFav: (textField?.text)!)
                    self.dismiss(animated: true, completion: nil)
                } else {
                    let newAlert = UIAlertController(title: "You can't pick that name!", message: "pick a differet name", preferredStyle: .alert)
                    newAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (_) in
                        self.dismiss(animated: true, completion: nil)
                    }))
                    self.present(newAlert, animated: true, completion: nil)
                }
            }))
            self.present(alert, animated: true, completion: nil)
        } else {
            delegate?.favoriteSelected(selection: options![indexPath.row])
            dismiss(animated: true, completion: nil)
        }
    }
    
    
    // handling deletion of options
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if options![indexPath.row] != "create new" {
            return true
        } else {
            return false
        }
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            self.options!.remove(at: indexPath.row)
            self.tableView.beginUpdates()
            self.tableView.deleteRows(at: [indexPath], with: .automatic)
            self.tableView.endUpdates()
            
            // creating an exit in case all favorites were deleted
            if options?.count == 0 {
                self.delegate?.favoritesEmpty()
                dismiss(animated: true, completion: nil)
            }
        }
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
