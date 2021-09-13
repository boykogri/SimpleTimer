//
//  TimersViewModel.swift
//  SimpleTimer
//
//  Created by Григорий Бойко on 11.09.2021.
//

import Foundation
import RealmSwift

protocol TimersViewModelDelegate: AnyObject {
    func updateTimerTasks()
    func removeCell(for indexPath: IndexPath)
    func updateUI()
}

class TimersViewModel {
    
    private var timerTasks: Results<TimerTask>
    private var timer: Timer?
    
    var timersCount: Int {
        timerTasks.count
    }
    
    weak var delegate: TimersViewModelDelegate?
    
    init() {
        timerTasks = StorageManager.shared.getAllTimerTasks()
        createTimerIfNedded()
    }
        
    func getTimerTask(for indexPath: IndexPath) -> TimerTask{
        return timerTasks[indexPath.row]
    }
    
    func addTimerTask(name: String, seconds: Int){
        StorageManager.shared.addObject(TimerTask(name: name, lastSeconds: seconds))
        createTimerIfNedded()
        delegate?.updateUI()
    }
    
    func deleteTimerTask(indexPath: IndexPath){
        let timerTask = timerTasks[indexPath.row]
        StorageManager.shared.deleteObject(timerTask)
        deleteTimerIfNedded()
        delegate?.removeCell(for: indexPath)

    }
    
    //MARK: - Timer
    private func createTimerIfNedded() {
        if timer == nil && timersCount > 0 { createTimer() }
    }
    private func deleteTimerIfNedded(){
        if timersCount == 0 {deleteTimer()}
    }
    
    private func createTimer() {
        let timer = Timer(timeInterval: 1.0,
                          target: self,
                          selector: #selector(updateTimer),
                          userInfo: nil,
                          repeats: true)
        RunLoop.current.add(timer, forMode: .common)
        timer.tolerance = 0.1
        
        self.timer = timer
        
    }
    
    private func deleteTimer() {
      timer?.invalidate()
      timer = nil
    }
    
    @objc private func updateTimer(){
        delegate?.updateTimerTasks()
    }


}
