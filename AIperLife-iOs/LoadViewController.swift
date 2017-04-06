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
    @IBOutlet var titleLabel: UILabel!
    
    let realm = try! Realm()
    
    @IBAction func LoadButton(_ sender: Any) {
        print("Loading Game")
    }
    
    @IBAction func cancelButton(_ sender: Any) {
        print("Regret Decision!")
        UIView.animate(withDuration: 0.5, animations: {
            self.confirmView.alpha = 0
        }) { (true) in
            self.titleLabel.text = "No title"
            self.confirmLabel.text = "No description available"
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        confirmView.alpha = 0
        titleLabel.text = "No title"
        confirmLabel.text = "No description available"
        print("load view loaded")
        
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
    
    //Action on click
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        UIView.animate(withDuration: 0.5, animations: {
            self.confirmView.alpha = 1.0
        })
        let resultArray = realm.objects(SaveData.self)
        if let saveTitle = resultArray[indexPath.row].title {
            titleLabel.text = saveTitle
        }
        if let saveDesc = resultArray[indexPath.row].desc {
            confirmLabel.text = "\(saveDesc). There are \(resultArray[indexPath.row].objList.count) objects to be found... Are you ready for the adventure?"
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? PlayGameViewController{
            destination.selectSave = tableView.indexPathForSelectedRow!.row
            print("Row Selected \(tableView.indexPathForSelectedRow!.row)")
        }
    }
}
