//
//  LoadViewController.swift
//  AIperLife-iOs
//
//  Created by Yi Kai Lee on 2017/3/7.
//  Copyright © 2017年 Eugenio Culurciello. All rights reserved.
//

import UIKit
import Foundation
import RealmSwift

class LoadViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var confirmView: UIView!
    @IBOutlet var confirmLabel: UILabel!
    @IBOutlet var titleLabel: UILabel!
    
    let mainColor = UIColor(red: 74/255, green: 189/255, blue: 172/255, alpha: 1)
    let verColor = UIColor(red: 252/255, green: 74/255, blue: 26/255, alpha: 1)
    let sunColor = UIColor(red: 247/255, green: 183/255, blue: 51/255, alpha: 1)
    let textColor = UIColor(red: 222/255, green: 220/255, blue: 227/255, alpha: 1)
    
    let realm = try! Realm()
    var items = [String]()
    
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
        // TODO: Maybe Revamp the confirm view later?
        confirmView.alpha = 0
        titleLabel.text = "No title"
        confirmLabel.text = "No description available"
        print("load view loaded")
        
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.backgroundColor = mainColor
    }

    override func viewDidAppear(_ animated: Bool) {
        //Table insertion animation
        var indexPaths = [IndexPath]()
        
        for i in 0...realm.objects(SaveData.self).count-1 {
            let resultArray = realm.objects(SaveData.self)
            items.append(resultArray[i].title!)
            indexPaths.append(IndexPath(row: i, section: 0))
            
            tableView.beginUpdates()
            if (i%2 == 0) {
                tableView.insertRows(at: [IndexPath(row: i, section: 0)], with: .left)
            } else {
                tableView.insertRows(at: [IndexPath(row: i, section: 0)], with: .right)

            }
            tableView.endUpdates()
        }
    }

    //Tableview cell styles
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if (indexPath.row % 2 == 0) {
            cell.backgroundColor = sunColor
        } else {
            cell.backgroundColor = verColor
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return realm.objects(SaveData.self).count
        return items.count
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
