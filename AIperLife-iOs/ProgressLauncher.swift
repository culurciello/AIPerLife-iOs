//
//  ProgressLauncher.swift
//  AIperLife-iOs
//
//  Created by Yi Kai Lee on 4/10/17.
//  Copyright © 2017 Yi Kai Lee. All rights reserved.
//

import UIKit
import RealmSwift

class ProgressLauncher: NSObject, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    
    let maskView = UIView()
    let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = UIColor.white
        return cv
    }()
    
    let cellId = "cellId"
    
    let realm = try! Realm()
    
    var numObj = 0
    
    func showProgress(){
        if let window = UIApplication.shared.keyWindow {
            maskView.backgroundColor = UIColor(white: 0, alpha: 0.5)
            maskView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleDismiss)))
            
            window.addSubview(maskView)
            window.addSubview(collectionView)
            
            let width: CGFloat = 200
            let x = window.frame.width - width
            collectionView.frame = CGRect(x: window.frame.width, y: 0, width: width, height: window.frame.height)
            
            maskView.frame = window.frame
            maskView.alpha = 0
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseInOut, animations: {
                self.maskView.alpha = 1
                self.collectionView.frame = CGRect(x: x, y: 0, width: self.collectionView.frame.width, height: self.collectionView.frame.height)
            }, completion: nil)
            
        }
    }
    
    func handleDismiss() {
        UIView.animate(withDuration: 0.5, animations: {
            self.maskView.alpha = 0
            if let window = UIApplication.shared.keyWindow {
                self.collectionView.frame = CGRect(x: window.frame.width, y: 0, width: self.collectionView.frame.width, height: self.collectionView.frame.height)
            }
        })
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return numObj
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath)
        //cell.frame.size = CGSize(width: self.collectionView.frame.width, height: 50)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: self.collectionView.frame.width, height: 50)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    init(selectSave: Int) {
        super.init()
        
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(ProgressCell.self, forCellWithReuseIdentifier: cellId)
        
        //TODO override init to get relevant info
        let result = realm.objects(SaveData.self)[selectSave]
        numObj = result.numObj
        
        
    }
}
