//
//  Utility.swift
//  AIperLife-iOs
//
//  Created by Yi Kai Lee on 2017/3/13.
//  Copyright © 2017年 Eugenio Culurciello. All rights reserved.
//

import Foundation
import UIKit

/*
 * This class holds useful utilitiy functions that may be required across different ViewControllers
 */
class Util {
    // resize and rescale func
    class func resizeImage(image: UIImage, newWidth: CGFloat) -> UIImage? {
        
        let scale = newWidth / image.size.width
        //new Height may not be nnEyeSize, rescale the height
        let tempH = image.size.height * scale
        let newHeight = (newWidth/tempH)*tempH
        
        UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
        image.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
}


extension UIView {
    func addConstraintsWithFormat(format: String, views: UIView...) {
        var viewsDictionary = [String: UIView]()
        for (index, view) in views.enumerated() {
            let key = "v\(index)"
            view.translatesAutoresizingMaskIntoConstraints = false
            viewsDictionary[key] = view
        }
        
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: format, options: NSLayoutFormatOptions(), metrics: nil, views: viewsDictionary))
    }
}
