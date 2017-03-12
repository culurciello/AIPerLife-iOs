//
//  SaveData.swift
//  AIperLife-iOs
//
//  Created by Yi Kai Lee on 2017/3/9.
//  Copyright © 2017年 Eugenio Culurciello. All rights reserved.
//

import Foundation
import RealmSwift

/*
 * SaveData contains meta data for a save file and list of objects
 *
 *
 * saveId:  a unique identifier for each save
 * title :  title of the save game
 * desc:    Description of the game
 * created: Date of creation (for ordering purpose)
 * numObj : number of object in the treasure list
 * objList: contains a list of treasure objects
 *
 */

class SaveData: Object {
    
    dynamic var saveId = NSUUID().uuidString
    dynamic var title : String? = nil
    dynamic var desc : String? = nil
    dynamic var created = NSDate()
    dynamic var numObj = 0
    let objList = List<Treasure>()
    
    override class func primaryKey() -> String? {
        return "saveId"
    }
    
    convenience init(title: String, numObj: Int) {
        self.init()
        self.title = title
        self.numObj = numObj
    }
}

/*
 * Treasure contains the data of each learned object
 *
 * order:    Order of the object in relation to another
 * treasure: Data of the object
 * hint:     Sting of text for description of a object
 * tresure:  list of floats
 *
 */

class Treasure: Object {
    dynamic var owner: SaveData?
    dynamic var order = -1
    dynamic var hint : String? = nil
    let treasure = List<FloatObject>()
}

/*
 * Realm cannot store arrays, this is a workaround class
 */

class FloatObject: Object {
    dynamic var value : Float = 0.0
}

