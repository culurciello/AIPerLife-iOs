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
    
    let datatitle = ["1","2","3","4","5"]
    let dataDate = ["a","b","c","d","e"]
    let dataNum = ["11","22","33","44","55"]
    let dataDsc = ["aa","bb","cc","dd","ee"]
    
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
//        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = Bundle.main.loadNibNamed("SaveDataTableViewCell", owner: self, options: nil)?.first as! SaveDataTableViewCell
        
        cell.selectionStyle = .none
        let dateF = DateFormatter()
        dateF.dateFormat = "MM/dd/yyyy"
        let resultArray = realm.objects(SaveData.self)
        cell.titleLabel?.text = resultArray[indexPath.row].title
        cell.dateCreatedLabel?.text = dateF.string(for: resultArray[indexPath.row].created as Date)
        cell.dateCreatedLabel.sizeToFit()
        cell.numObjectsLabel?.text = "\(resultArray[indexPath.row].numObj)"
        cell.descriptionLabel?.text = resultArray[indexPath.row].desc
//        cell.titleLabel?.text = datatitle[indexPath.row]
//        cell.dateCreatedLabel?.text = dataDate[indexPath.row]
//        cell.numObjectsLabel?.text = dataNum[indexPath.row]
//        cell.descriptionLabel?.text = dataDsc[indexPath.row]

        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 116
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
    
    //navigation bar manipulation
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
}
