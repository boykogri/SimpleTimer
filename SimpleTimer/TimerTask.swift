//
//  TimerTask.swift
//  SimpleTimer
//
//  Created by Григорий Бойко on 11.09.2021.
//

import Foundation
import RealmSwift

class TimerTask: Object {
    
    @Persisted private var endDate = Date()
    @Persisted private var savedDate = TimeInterval()
    @Persisted var name: String
    @Persisted var isActive = true {
        willSet {
            newValue ? resumeTimer() : stopTimer()
        }
    }
    
    var lastSeconds: TimeInterval {
        var last: TimeInterval!
        if isActive {
            last = -Date().timeIntervalSince(endDate)
        }else {
            last = savedDate
        }
        return last
    }
    
    convenience init(name: String, lastSeconds: Int) {
        self.init()
        
        self.name = name
        self.endDate = Date(timeIntervalSinceNow: TimeInterval(lastSeconds))
    }
    
    private func stopTimer(){
        savedDate = -Date().timeIntervalSince(endDate)
    }
    private func resumeTimer(){
        endDate = Date(timeIntervalSinceNow: savedDate)
    }
}
