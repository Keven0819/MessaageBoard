//
//  DataBase.swift
//  MessageBoard
//
//  Created by imac-2627 on 2024/7/18.
//

import Foundation
import RealmSwift

class MessageBoard: Object {
    @Persisted(primaryKey: true) var _id: ObjectId
    @Persisted var name: String = ""
    @Persisted var content: String = ""
    @Persisted var currentTime: String = ""

    convenience init(name: String, content: String, currentTime: String) {
        self.init()
        self.name = name
        self.content = content
        self.currentTime = currentTime
   }
}

