//
//  MenuViewController.swift
//  AIperLife-iOs
//
//  Created by Yi Kai Lee on 2017/3/6.
//  Copyright © 2017 Eugenio Culurciello. All rights reserved.
//

import UIKit

class MenuViewController: UIViewController {

    
    @IBOutlet var playButton: UIButton!
    @IBOutlet var createButton: UIButton!
    @IBOutlet var loadButton: UIButton!
    
    //Proceed to play game
    @IBAction func playPressed(_ sender: Any) {
        print("play button pressed")
    }
    
    //Proceed to create game
    @IBAction func createPressed(_ sender: Any) {
        print("create button pressed")
    }

    //Proceed to load saved games
    @IBAction func loadPressed(_ sender: Any) {
        print("load button pressed")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        print("menu loaded")
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
