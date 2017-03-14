//
//  CreateViewController.swift
//  AIperLife-iOs
//
//  Created by Yi Kai Lee on 2017/3/13.
//  Copyright © 2017年 Eugenio Culurciello. All rights reserved.
//

import UIKit
import AVFoundation

protocol LearnFrameDelegate: class {
    func captured(image: UIImage)
}

class LearnFrame: FrameExtractor {
    weak var delegate: LearnFrameDelegate?
    
    override func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputSampleBuffer sampleBuffer: CMSampleBuffer!, from connection: AVCaptureConnection!) {
        guard let uiImage = imageFromSampleBuffer(sampleBuffer: sampleBuffer) else { return }
        DispatchQueue.main.async {
            [unowned self] in
            self.delegate?.captured(image: uiImage)
        }
    }
}

class CreateViewController: UIViewController, LearnFrameDelegate {

    var lFrame : LearnFrame!
    
    var item = 0
    
    @IBOutlet var imageView: UIImageView!
    
    @IBAction func learnPressed(_ sender: Any) {
        let defaults = UserDefaults.standard
        let image = Util.resizeImage(image: imageView.image!, newWidth: 128)
        
        if item == 0 {
            //save image
            let imageData:NSData = UIImagePNGRepresentation(image!)! as NSData
            defaults.set(imageData, forKey: "savedImage" + String(0))
            print("Current scene saved!")
            item = 1
        } else {
            let imageData:NSData = UIImagePNGRepresentation(image!)! as NSData
            defaults.set(imageData, forKey: "savedImage" + String(1))
            print("Current scene saved!")
            item = 2
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        lFrame = LearnFrame()
        lFrame.delegate = self
    }
    
    func captured(image: UIImage) {
        imageView.image = image
    }
    
    override func viewWillLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        //Manage the UIView Rotations
        let currentDevice: UIDevice = UIDevice.current
        let orientation: UIDeviceOrientation = currentDevice.orientation
        switch (orientation) {
        case .landscapeRight:
            imageView.transform = CGAffineTransform(rotationAngle: CGFloat.pi/2)
            break
        case .landscapeLeft:
            imageView.transform = CGAffineTransform(rotationAngle: CGFloat.pi/2*3)
            break
        default:
            imageView.transform = CGAffineTransform(rotationAngle: CGFloat.pi*2)
            break
        }
    }
}
