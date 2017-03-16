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

    let realm = try! Realm()
    let defaults = UserDefaults.standard
    
    @IBOutlet var tableView: UITableView!
    
    @IBAction func deleteAllPressed(_ sender: Any) {
        //Warning before deleting all data
        let alertController = UIAlertController(title: "Caution!", message: "You are about to erase all saved games. Do you wish to proceed?", preferredStyle: UIAlertControllerStyle.alert)
        let EraseAction = UIAlertAction(title: "Erase", style: UIAlertActionStyle.destructive) {
            (result : UIAlertAction) -> Void in
            
            //remove all objects in realm
            try! self.realm.write {
                print("deleting all items in realm")
                self.realm.deleteAll()
            }
            
            //remove all object in test saves
            self.tableView.reloadData()
            
            //remove all UserDefaults
            self.defaults.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
        }
        let cancelAction = UIAlertAction(title: "cancel", style: UIAlertActionStyle.default) {
            (result : UIAlertAction) -> Void in
            print("cancel")
        }
        
        alertController.addAction(EraseAction)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.tableView.dataSource = self
        self.tableView.delegate = self
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return realm.objects(SaveData.self).count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.selectionStyle = .none
        let resultArray = realm.objects(SaveData.self)
        cell.textLabel!.text = resultArray[indexPath.row].title
        return cell
    }
    
    //Swipe to delete individual entry
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let deleteObj = realm.objects(SaveData.self)[indexPath.row]
            let deleteList = deleteObj.objList
            print("deleting \(deleteObj.title) with \(deleteList.count) objects")
            //remove image data stored with userdefault
            for idx in deleteList {
                self.defaults.removeObject(forKey: idx.objID)
            }
            //remove realm data
            try! self.realm.write{
                self.realm.delete(deleteList)
                self.realm.delete(deleteObj)
            }
            //update tableview
            self.tableView.reloadData()
        }
     }
}
