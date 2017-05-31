//
//  ProgressLauncher.swift
//  AIperLife-iOs
//
//  Created by Yi Kai Lee on 4/10/17.
//  Copyright © 2017 Yi Kai Lee. All rights reserved.
//

import UIKit
import RealmSwift

class Progress: NSObject {
    var name: String
    var imageName: String
    var found: Bool
    
    init(name: String, imageName: String) {
        self.name = name
        self.imageName = imageName
        self.found = false
    }
}


class ProgressLauncher: NSObject, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    let maskView = UIView()
    let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = UIColor.white
        return cv
    }()
    
    let cellId = "cellId"
    let cellHeight: CGFloat = 50
    
    let realm = try! Realm()
    var numObj = 0
    var progress: [Progress] = []
    
    func showProgress(){
        if let window = UIApplication.shared.keyWindow {
            maskView.backgroundColor = UIColor(white: 0, alpha: 0.5)
            maskView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleDismiss)))
            
            window.addSubview(maskView)
            window.addSubview(collectionView)
            
            let height: CGFloat = 250
            let y = window.frame.height - height
            collectionView.frame = CGRect(x: 0, y: window.frame.height, width: window.frame.width, height: height)
            
            maskView.frame = window.frame
            maskView.alpha = 0
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseInOut, animations: {
                self.maskView.alpha = 1
                self.collectionView.frame = CGRect(x: 0, y: y, width: self.collectionView.frame.width, height: self.collectionView.frame.height)
            }, completion: nil)
            
        }
    }
    
    func handleDismiss() {
        UIView.animate(withDuration: 0.5, animations: {
            self.maskView.alpha = 0
            if let window = UIApplication.shared.keyWindow {
                //disappearing to bottom
                self.collectionView.frame = CGRect(x: 0, y: window.frame.height, width: self.collectionView.frame.width, height: self.collectionView.frame.height)
                //disappear to top right
                //self.collectionView.frame = CGRect(x: window.frame.width, y: 0, width: self.collectionView.frame.width, height: self.collectionView.frame.height)
            }
        })
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return numObj
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! ProgressCell
        cell.setting = progress[indexPath.item]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.collectionView.frame.width, height: cellHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    init(selectSave: Int) {
        super.init()
        
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(ProgressCell.self, forCellWithReuseIdentifier: cellId)
        
        //Initialize cells
        let result = realm.objects(SaveData.self)[selectSave]
        let objList = result.objList
        numObj = result.numObj
        for item in objList {
            progress.append(Progress(name: item.hint, imageName: "not_found"))
        }
    }
    
    func updateProgress(item: Int) {
        progress[item].imageName = "found"
        progress[item].found = true
        self.collectionView.reloadData()
    }
    
    let itemView: UIView = {
        let iv = UIView(frame: .zero)
        iv.backgroundColor = UIColor(patternImage: UIImage(named: "Border")!)
        return iv
    }()
    
    
    let hintLabel: UILabel = {
        let hl = UILabel()
        hl.textAlignment = .center
        hl.translatesAutoresizingMaskIntoConstraints = false
        return hl
    }()
    
    func addProgress(curritem: Int, pastitem: Int) {
        if pastitem == curritem {
            return
        }
        
        if let window = UIApplication.shared.keyWindow {
            maskView.backgroundColor = UIColor(white: 0, alpha: 0.5)
            maskView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(storeItem)))
            maskView.frame = window.frame
            maskView.alpha = 0
            
            window.addSubview(maskView)
            window.addSubview(itemView)
            
            hintLabel.text = self.progress[curritem].name
            
            itemView.addSubview(hintLabel)
            hintLabel.centerXAnchor.constraint(equalTo: itemView.centerXAnchor).isActive = true
            hintLabel.centerYAnchor.constraint(equalTo: itemView.centerYAnchor).isActive = true
            hintLabel.widthAnchor.constraint(equalTo: itemView.widthAnchor, constant: 8).isActive = true
            hintLabel.heightAnchor.constraint(equalTo: itemView.heightAnchor, constant: 4).isActive = true
            
            let itemImage = UIImage(named: "Border")
            let height = itemImage?.size.height
            let width = itemImage?.size.width
            
            let offset: CGFloat = 40
            let y = window.frame.height - height! - offset
            let x = (window.frame.width-width!)/2
            
            itemView.frame = CGRect(x: x, y: window.frame.height/2, width: width!, height: height!)
            
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseInOut, animations: {
                self.maskView.alpha = 1
                self.itemView.frame = CGRect(x: x, y: y, width: self.itemView.frame.width, height: self.itemView.frame.height)
                print(self.progress[curritem].name)
            }, completion: nil)
            
        }
    }
    
    func storeItem() {
        UIView.animate(withDuration: 0.3, animations: {
            self.maskView.alpha = 0
            if let window = UIApplication.shared.keyWindow {
                //disappear to top right
                self.itemView.frame = CGRect(x: window.frame.width, y: 0, width: self.itemView.frame.width, height: self.itemView.frame.height)
            }
        })
    }
}
