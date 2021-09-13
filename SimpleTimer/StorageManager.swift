//
//  StorageManager.swift
//  SimpleTimer
//
//  Created by Григорий Бойко on 12.09.2021.
//

import Foundation
import RealmSwift

class StorageManager{
    private let realm = try! Realm()
    static let shared = StorageManager()
    
    private init(){}
    
    func addObject(_ object: Object){
        try! realm.write {
            realm.add(object)
        }
    }
    func deleteObject(_ object: Object){
        try! realm.write {
            realm.delete(object)
        }
    }
    
    func changeObject(completion: @escaping ()->()){
        try! realm.write {
            completion()
        }
    }
    
    func getAllTimerTasks() -> Results<TimerTask>{
        realm.objects(TimerTask.self)
    }
}
