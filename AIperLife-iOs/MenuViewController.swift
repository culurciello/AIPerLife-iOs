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
    
    let loadAnim = LoadingAnimator()
    
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
        //Loading Animation
        loadAnim.showAnimation()
        
        //Hide navigation bar
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
}
