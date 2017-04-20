//
//  LoadAnimator.swift
//  AIperLife-iOs
//
//  Created by Yi Kai Lee on 4/12/17.
//  Copyright © 2017 Yi Kai Lee. All rights reserved.
//

import UIKit

class LoadingAnimator: NSObject {
    
    //Place these outside show animation for one time display
    let maskView = UIView()
    let icon = UIImageView()
    
    let r : CGFloat = 74/255
    let g : CGFloat = 189/255
    let b : CGFloat = 172/255
    
    func showAnimation() {
        if let window = UIApplication.shared.keyWindow {
            maskView.backgroundColor = UIColor.init(red: r, green: g, blue: b, alpha: 1)
            maskView.frame = window.frame
            
            icon.image = UIImage(named: "Logo_cube_white")
            icon.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
            icon.center = CGPoint(x: maskView.frame.width/2, y: maskView.frame.height/2)
            
            window.addSubview(maskView)
            window.addSubview(icon)
            
            
            
            UIView.animate(withDuration: 0.25, animations: {
                self.icon.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
            }) { (true) in
                UIView.animate(withDuration: 0.75, animations: {
                    self.icon.transform = CGAffineTransform(scaleX: 1000, y: 1000)
                    self.icon.alpha = 0
                    self.maskView.alpha = 0
                })
            }
        }
    }
}
