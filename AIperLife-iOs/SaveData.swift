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
 * title :  title of the save game
 * desc:    Description of the game
 * created: Date of creation (for ordering purpose)
 * numObj : number of object in the treasure list
 * objList: contains a list of treasure objects
 *
 */

class SaveData: Object {
    
    dynamic var taskId = NSUUID().uuidString
    dynamic var title : String? = nil
    dynamic var desc : String? = nil
    dynamic var created = NSDate()
    dynamic var numObj = 0
    let objList = List<Treasure>()
    
    convenience init(title: String) {
        self.init()
        self.title = title
    }
    
    override class func primaryKey() -> String? {
        return "taskId"
    }
    
}

/*
 * Treasure contains the data of each learned object
 *
 * objID:    Unique identifier for each object
 * order:    Order of the object in relation to another
 * hint:     Sting of text for hint of a object
 *
 */

class Treasure: Object {
    dynamic var order = -1
    dynamic var hint = "no hint"
    dynamic var objID = NSUUID().uuidString

}

