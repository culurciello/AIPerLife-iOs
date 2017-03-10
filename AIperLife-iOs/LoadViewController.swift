//
//  LoadViewController.swift
//  AIperLife-iOs
//
//  Created by Yi Kai Lee on 2017/3/7.
//  Copyright © 2017年 Eugenio Culurciello. All rights reserved.
//

import UIKit

class LoadViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var confirmView: UIView!
    @IBOutlet var confirmLabel: UILabel!
    
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

    var testsaves = ["Save 1", "Save 2", "Save 3", "Save 4"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        confirmView.alpha = 0
        print("load view loaded")
        
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
    
    //Action on click
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Clicked on \(testsaves[indexPath.row])")
        
        UIView.animate(withDuration: 1.0, animations: {
            self.confirmView.alpha = 1.0
        })
        
        confirmLabel.text = "\(testsaves[indexPath.row]) selected, There are XXX objects to be found... Are you ready for the adventure?"
    }
}
