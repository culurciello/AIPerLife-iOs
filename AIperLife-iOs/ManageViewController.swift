//
//  ManageViewController.swift
//  AIperLife-iOs
//
//  Created by Yi Kai Lee on 2017/3/10.
//  Copyright © 2017年 Eugenio Culurciello. All rights reserved.
//

import UIKit
import RealmSwift

class ManageViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet var tableView: UITableView!
    
    @IBAction func deleteAllPressed(_ sender: Any) {
        //Warning before deleting all data
        let alertController = UIAlertController(title: "Caution!", message: "You are about to erase all saved games. Do you wish to proceed?", preferredStyle: UIAlertControllerStyle.alert)
        let EraseAction = UIAlertAction(title: "Erase", style: UIAlertActionStyle.destructive) {
            (result : UIAlertAction) -> Void in
            
            //remove all objects in realm
            let realm = try! Realm()
            try! realm.write {
                print("deleting all items in realm")
                realm.deleteAll()
            }
            
            //remove all object in test saves
            self.testsaves.removeAll()
            self.tableView.reloadData()
            
            //remove all UserDefaults
            let defaults = UserDefaults.standard
            defaults.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
        }
        let cancelAction = UIAlertAction(title: "cancel", style: UIAlertActionStyle.default) {
            (result : UIAlertAction) -> Void in
            print("cancel")
        }
        
        alertController.addAction(EraseAction)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    var testsaves = ["Save 1", "Save 2", "Save 3", "Save 4"]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.tableView.dataSource = self
        self.tableView.delegate = self
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.testsaves.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.selectionStyle = .none
        cell.textLabel!.text = self.testsaves[indexPath.row]
        return cell
    }
    
    //Swipe to delete individual entry
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            print("delete")
            //Perform relevant delete functions
            self.testsaves.remove(at: indexPath.row)
            //update tableview
            self.tableView.reloadData()
        }
     }
}
