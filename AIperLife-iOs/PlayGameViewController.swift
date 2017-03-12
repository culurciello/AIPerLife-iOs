//
//  PlayGameViewController.swift
//  AIperLife-iOs
//
//  Created by Yi Kai Lee on 2017/3/9.
//  Copyright © 2017年 Eugenio Culurciello. All rights reserved.
//

import UIKit
import AVFoundation

class PlayGameViewController: UIViewController, FrameExtractorDelegate {
    
    var frameExtractor : FrameExtractor!

    @IBOutlet var playImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        frameExtractor = FrameExtractor()
        frameExtractor.delegate = self

    }
    
    func captured(image: UIImage) {
        playImageView.image =  image
    }
    
    override func viewWillLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        //Manage the UIView Rotations
        let currentDevice: UIDevice = UIDevice.current
        let orientation: UIDeviceOrientation = currentDevice.orientation
        switch (orientation) {
            case .landscapeRight:
                playImageView.transform = CGAffineTransform(rotationAngle: CGFloat.pi/2)
                break
            case .landscapeLeft:
                playImageView.transform = CGAffineTransform(rotationAngle: CGFloat.pi/2*3)
                break
            default:
                playImageView.transform = CGAffineTransform(rotationAngle: CGFloat.pi*2)
                break
        }
    }
}
