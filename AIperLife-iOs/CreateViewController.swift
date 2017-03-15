//
//  CreateViewController.swift
//  AIperLife-iOs
//
//  Created by Yi Kai Lee on 2017/3/13.
//  Copyright © 2017年 Eugenio Culurciello. All rights reserved.
//

import UIKit
import AVFoundation
import RealmSwift


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
        
        //Prompt to enter hint
        var hintField: UITextField!
        func configurationTextField(textField: UITextField!)
        {
            //Alert Configuration
            textField.placeholder = "Enter here!"
            hintField = textField
        }
        func handleCancel(alertView: UIAlertAction!)
        {
            //cancel text input and cancel learning
            print("Cancelled !!")
        }
        //Create Alert
        let alert = UIAlertController(title: "Enter Hint", message: "", preferredStyle: .alert)
        alert.addTextField(configurationHandler: configurationTextField)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler:handleCancel))
        alert.addAction(UIAlertAction(title: "Done", style: .default, handler:{ (UIAlertAction) in
            //save image
            let imageData:NSData = UIImagePNGRepresentation(image!)! as NSData
            defaults.set(imageData, forKey: "savedImage" + String(self.item))
            print("item \(self.item+1) saved!")
            self.item += 1
            //print for debugging
            print("Item : \(hintField.text)")
        }))
        self.present(alert, animated: true, completion: { print("completed saving") })
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
