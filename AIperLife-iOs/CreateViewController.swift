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
    
    //Setup Input Container
    let inputsView : UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white
        view.layer.cornerRadius = 6
        view.layer.masksToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    //Setup Buttons
    lazy var confirmSaveButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = UIColor(red: 80/255, green: 200/255, blue: 180/255, alpha: 1)
        button.setTitle("Save", for: .normal)
        button.setTitleColor(UIColor.white, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.addTarget(self, action: #selector(handleSave), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    //Setup contents of input container [title text field, seperator, desc test field]
    let titleTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Title for Save"
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    
    let seperatorView : UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 220/225, green: 220/225, blue: 220/225, alpha: 1)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let descTextField: UITextView = {
        let tf = UITextView()
        tf.isEditable = true
        tf.text = "Description / First hint"
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    
    //create realm object
    let currData = SaveData(title: "Unnamed Save")
    
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var saveButton: UIBarButtonItem!
    
    let summaryView = UIView()
    
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
                self.currData.objList.append(myObj)
                self.currData.numObj = self.currData.objList.count
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
        
        self.titleTextField.delegate = self
        
        saveButton.isEnabled = false
        
        //Manage Summary View
        //TODO figure out a way to use "view" instead of window
        if let window = UIApplication.shared.keyWindow {
            window.addSubview(summaryView)
            summaryView.frame = view.frame
            summaryView.alpha = 0
            summaryView.backgroundColor = UIColor(red: 74/255, green: 189/255, blue: 172/255, alpha: 1)
            
            summaryView.addSubview(inputsView)
            summaryView.addSubview(confirmSaveButton)
            
            
            setupInputsView()
            setupConfirmSaveButton()
        }
        
    }
    
    func captured(image: UIImage) {
        imageView.image = image
    }
    
    @IBAction func savePressed(_ sender: Any) {
        //setup save summary
        summaryView.alpha = 1
    }
    
    func handleSave() {
        //save to realm
        self.currData.title = titleTextField.text
        self.currData.desc = descTextField.text
        try! self.realm.write {
            realm.add(currData, update: true)
        }
        
        //hide keyboards
        descTextField.resignFirstResponder()
        titleTextField.resignFirstResponder()
        
        //TODO make sure we don't need to use this
        summaryView.alpha = 0
        
        //return to main menu
        _ = navigationController?.popViewController(animated: true)
    }
    
    func setupInputsView() {
        //inputs view box constraints
        inputsView.centerXAnchor.constraint(equalTo: summaryView.centerXAnchor).isActive = true
        inputsView.centerYAnchor.constraint(equalTo: summaryView.centerYAnchor, constant: -100).isActive = true
        inputsView.widthAnchor.constraint(equalTo: summaryView.widthAnchor, constant: -32).isActive = true
        inputsView.heightAnchor.constraint(equalToConstant: 150).isActive = true
        
        inputsView.addSubview(titleTextField)
        inputsView.addSubview(seperatorView)
        inputsView.addSubview(descTextField)
        
        //Title Text Field constraints
        titleTextField.leftAnchor.constraint(equalTo: inputsView.leftAnchor, constant: 8).isActive = true
        titleTextField.topAnchor.constraint(equalTo: inputsView.topAnchor).isActive = true
        titleTextField.widthAnchor.constraint(equalTo: inputsView.widthAnchor).isActive = true
        titleTextField.heightAnchor.constraint(equalTo: inputsView.heightAnchor, multiplier: 1/3).isActive = true
        
        //Seperator Constraints
        seperatorView.leftAnchor.constraint(equalTo: inputsView.leftAnchor).isActive = true
        seperatorView.topAnchor.constraint(equalTo: titleTextField.bottomAnchor).isActive = true
        seperatorView.widthAnchor.constraint(equalTo: inputsView.widthAnchor).isActive = true
        seperatorView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        //Description Text Field Constraints
        descTextField.leftAnchor.constraint(equalTo: inputsView.leftAnchor, constant: 8).isActive = true
        descTextField.topAnchor.constraint(equalTo: seperatorView.bottomAnchor).isActive = true
        descTextField.widthAnchor.constraint(equalTo: inputsView.widthAnchor).isActive = true
        descTextField.heightAnchor.constraint(equalTo: inputsView.heightAnchor, multiplier: 2/3).isActive = true
        
    }
    
    func setupConfirmSaveButton() {
        //button constraints
        confirmSaveButton.centerXAnchor.constraint(equalTo: summaryView.centerXAnchor).isActive = true
        confirmSaveButton.topAnchor.constraint(equalTo: inputsView.bottomAnchor, constant: 12).isActive = true
        confirmSaveButton.widthAnchor.constraint(equalTo: inputsView.widthAnchor).isActive = true
        confirmSaveButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
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
        
        if let window = UIApplication.shared.keyWindow {
            self.summaryView.frame = window.frame
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
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        titleTextField.resignFirstResponder()
        return true
    }

}
