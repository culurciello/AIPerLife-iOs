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

class CreateViewController: UIViewController, UITextFieldDelegate, LearnFrameDelegate {

    var lFrame : LearnFrame!
    var item = 0
    let realm = try! Realm()
    
    //create a test realm object
    let testingData = SaveData(title: "Unnamed Save")
    
    @IBOutlet var imageView: UIImageView!
    @IBOutlet weak var summaryView: UIView!
    @IBOutlet weak var titleField: UITextField!
    @IBOutlet weak var descField: UITextField!
    @IBOutlet var saveButton: UIBarButtonItem!
    
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
            let myObj = Treasure()
            let imageData:NSData = UIImagePNGRepresentation(image!)! as NSData
            myObj.order = self.item
            myObj.hint = hintField.text!
            //use the unique ID for each treasure object as key
            defaults.set(imageData, forKey: myObj.objID)
            try! self.realm.write {
                //write object into realm
                self.realm.add(myObj)
                //update meta data
                self.testingData.objList.append(myObj)
                self.testingData.numObj = self.testingData.objList.count
            }
            self.item += 1
            //enable saving after 2 objects learned
            if(self.item > 1) {
                self.saveButton.isEnabled = true
            }
        }))
        self.present(alert, animated: true, completion: {
            print("saving item \(self.item+1)")
        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        lFrame = LearnFrame()
        lFrame.delegate = self
        self.titleField.delegate = self
        self.descField.delegate = self
        
        saveButton.isEnabled = false
        summaryView.alpha = 0
        titleField.placeholder = "Enter Title..."
        descField.placeholder = "Enter brief description for your save..."
    }
    
    func captured(image: UIImage) {
        imageView.image = image
    }
    
    @IBAction func savePressed(_ sender: Any) {
        //setup save summary
        summaryView.alpha = 1
        
    }
    @IBAction func confirmPressed(_ sender: Any) {
        //save to realm
        self.testingData.title = titleField.text
        self.testingData.desc = descField.text
        try! self.realm.write {
            realm.add(testingData, update: true)
        }
        //return to main menu
        _ = navigationController?.popViewController(animated: true)
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        self.lFrame.captureSession.stopRunning()
    }
    
    //Hide keyboard when end editing and press return
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        titleField.resignFirstResponder()
        descField.resignFirstResponder()
        return true
    }
}
