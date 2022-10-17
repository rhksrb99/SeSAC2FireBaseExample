//
//  Todo.swift
//  SeSAC2FireBaseExample
//
//  Created by 박관규 on 2022/10/13.
//

import Foundation
import RealmSwift

class Todo: Object {
    @Persisted var title : String
    @Persisted var favorite : Double
    @Persisted var userDecription: String
    @Persisted var count : Int
    
    
    @Persisted(primaryKey: true) var objectId: ObjectId
    
    convenience init(title: String, importance: Int) {
        self.init()
        self.title = title
        self.favorite = Double(importance)
    }
    
}


