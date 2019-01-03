//
//  Level.swift
//  Sudoku3D
//
//  Created by Reid on 2018-11-08.
//  Copyright © 2018 Reid. All rights reserved.
//

import Foundation
import CoreData
import UIKit

enum LevelStatus {
    case normal
    case wonAgain
    case wonFirstTime
    case undidWin
}

protocol LevelObserver {
    var id : Int { get }
    func update(block : Int, colorIndex: UInt8, status : LevelStatus)
    func update(state : [UInt8] , complete : Bool)
}

class SudokuLevel {
    static let answerHandler = AnswerHandler()
    var state : [UInt8] = []
    var _hasPassed : Bool = false
    var hasPassed : Bool {
        set {_hasPassed = newValue}
        get {return _hasPassed}
    }
    var _isComplete : Bool = false
    var isComplete : Bool {
        set {_isComplete = newValue}
        get {return _isComplete}
    }
    var levelNumber : Int
    var dimension : Int
    var observers : [LevelObserver]  = []

    init(level: Int) {
        levelNumber = level
        dimension = level < 4 ? 3 : (level < 12 ? 4 : 5)
        if let result = getSavedLevel()
        {
            if let levelNumber = result.value(forKey: "levelNumber") as? Int
            {
                self.levelNumber = levelNumber
            }
            if let hp = result.value(forKey: "hasPassed") as? Bool
            {
                self.hasPassed = hp
            }
            if let ic = result.value(forKey: "isComplete") as? Bool
            {
                self.isComplete = ic
            }
            if let data = result.value(forKey: "state") as? NSData
            {
                var arrayLength = dimension*dimension*dimension
                arrayLength = arrayLength % 2 == 0 ? arrayLength/2 : (arrayLength/2 + 1)
                self.state = SudokuLevel.dataToColorIndexArray(withData: data, arrayLength: arrayLength)
            }
        }
        else
        {
            self.state = SudokuLevel.dataArrayToColorIndexArray(withArray: Constants.Levels[levelNumber]!)
        }
        for observer in observers {
            observer.update(state : state , complete: isComplete)
        }
    }

    func randomLevel() {
        self.isComplete = false
        self.state = SudokuLevel.answerHandler.pickRandomSoln(size: dimension)
        let percentMissing = 60 + arc4random_uniform(20)
        for i in 0..<dimension*dimension*dimension {
            if arc4random_uniform(100) < percentMissing {
                self.state[i] = 0
            }
        }
        for observer in observers {
            observer.update(state : state , complete: isComplete)
        }
    }
    
    func addObserver(_ obs : LevelObserver) {
        observers.append(obs)
        obs.update(state : state , complete: isComplete)
    }
    
    func removeObserver(_ obs : LevelObserver) {
        observers = observers.filter{ $0.id != obs.id}
    }
    
    func getLevelNumber() -> Int {
        return levelNumber
    }
    
    func getColour(_ i:Int) -> UInt8 {
        return state[i]
    }
    
    func getDimension() -> Int {
        return dimension
    }
    
    func getSize() -> Int {
        return dimension * dimension * dimension
    }
    
    func nextColor(atIndex index : Int) {
        if state[index] > 5 { return }
        setColor(colorIndex: UInt8((state[index] + 1) % (UInt8(dimension + 1))) ,atIndex: index)
    }

    func setColor(colorIndex color : UInt8, atIndex index : Int) {
        state[index] = color
        var status : LevelStatus = .normal
        if AnswerHandler.checkAnswer(state,mostRecentIndexChanged: index) {
            isComplete = true
            if hasPassed {
                status = .wonAgain
            } else {
                hasPassed = true
                status = .wonFirstTime
            }
        } else if isComplete {
            isComplete = false
            status = .undidWin
        }
        for observer in observers {
            observer.update(block: index, colorIndex: color, status: status)
        }
    }
    
    func resetLevel() {
        for i in 0..<state.count {
            if state[i] < 6 {state[i] = 0}
        }
        for observer in observers {
            observer.update(state: state, complete: false)
        }
    }
    
    func persistData() {
        var level : SudokuLevelMO
        if let result = getSavedLevel() {
            level = result
        } else {
            level = NSEntityDescription.insertNewObject(forEntityName: "Level", into: AppDelegate.context) as! SudokuLevelMO
        }
        level.setValue(levelNumber, forKey: "levelNumber")
        level.setValue(hasPassed, forKey: "hasPassed")
        level.setValue(isComplete, forKey: "isComplete")
        let data = SudokuLevel.colorIndexArrayToData(state)
        level.setValue(data, forKey: "state")
        do
        {
            try AppDelegate.context.save()
        }
        catch
        {
            //TODO: Error handling.
        }
    }

    private func getSavedLevel() -> SudokuLevelMO? {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Level")
        request.returnsObjectsAsFaults = false
        do
        {
            request.predicate = NSPredicate(format: "levelNumber = \(levelNumber)")
            let results = try AppDelegate.context.fetch(request) as! [SudokuLevelMO]
            if results.count < 1 { return nil }
            return results[0]
        }
        catch
        {
            return nil
        }
    }
    
    private static func colorIndexArrayToData(_ stateTemp:[UInt8]) -> NSData {
        var array : [UInt8] = []
        var temp : UInt8?
        for i in 0..<stateTemp.count {
            if i % 2 == 0 {
                temp = stateTemp[i] << 4
                // If there are an odd number of cubes.
                if i+1 == stateTemp.count {
                    array.append(temp!)
                }
            }
            else {
                array.append(temp! | (stateTemp[i] & 0xf))
                temp = nil
            }
        }
        return NSData(bytes: array, length: array.count)
    }
    
    private static func dataToColorIndexArray(withData data: NSData, arrayLength : Int) -> [UInt8] {
        var array : [UInt8] = Array(repeating: 0, count: arrayLength)
        data.getBytes(&array, length:arrayLength)
        return dataArrayToColorIndexArray(withArray: array)
    }
    
    private static func dataArrayToColorIndexArray(withArray array: [UInt8]) -> [UInt8] {
        var stateTemp : [UInt8] = []
        for i in 0..<array.count{
            stateTemp.append((array[i] >> 4 ) & 0xf)
            // If not the last elem of an odd dimension cube
            if !((i + 1 == array.count) && (i == 13 || i == 62)) {
                stateTemp.append(array[i] & 0xf)
            }
        }
        return stateTemp
    }
}
