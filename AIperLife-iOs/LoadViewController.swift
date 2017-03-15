//
//  LoadViewController.swift
//  AIperLife-iOs
//
//  Created by Yi Kai Lee on 2017/3/7.
//  Copyright © 2017年 Eugenio Culurciello. All rights reserved.
//

import UIKit
import RealmSwift

class LoadViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var confirmView: UIView!
    @IBOutlet var confirmLabel: UILabel!
    
    let realm = try! Realm()
    
    @IBAction func LoadButton(_ sender: Any) {
        print("Loading Game")
        
        //do all the load game opeations
    }
    
    
    @IBAction func cancelButton(_ sender: Any) {
        print("Regret Decision!")
        UIView.animate(withDuration: 1.0, animations: {
            self.confirmView.alpha = 0
        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        confirmView.alpha = 0
        print("load view loaded")
        
        self.tableView.dataSource = self
        self.tableView.delegate = self

    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //let someDogs = realm.objects(Dog.self).filter("name contains 'Fido'")
        return realm.objects(SaveData.self).count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = UITableViewCell()
        cell.selectionStyle = .none
        let resultArray = realm.objects(SaveData.self)
        cell.textLabel!.text = resultArray[indexPath.row].title
        return cell
    }
    
    //Action on click
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        UIView.animate(withDuration: 0.5, animations: {
            self.confirmView.alpha = 1.0
        })
        let resultArray = realm.objects(SaveData.self)
        
        confirmLabel.text = "\(resultArray[indexPath.row].title) selected, There are \(resultArray[indexPath.row].objList.count) objects to be found... Are you ready for the adventure?"
    }
}
