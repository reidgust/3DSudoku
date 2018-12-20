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

class SudokuLevel {
    static let answerHandler = AnswerHandler()
    var state : [UIColor] = []
    var hasPassed : Bool = false
    var isLocked : Bool = false
    var levelNumber : Int
    var dimension : Int
    
    init(level: Int) {
        levelNumber = level
        dimension = level < 3 ? 3 : (level < 12 ? 4 : 5)
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
            if let il = result.value(forKey: "isLocked") as? Bool
            {
                self.isLocked = il
            }
            if let data = result.value(forKey: "state") as? NSData
            {
                var arrayLength = dimension*dimension*dimension
                arrayLength = arrayLength % 2 == 0 ? arrayLength/2 : (arrayLength/2 + 1)
                self.state = SudokuLevel.dataToColorArray(withData: data, arrayLength: arrayLength)
            }
        }
        else
        {
            let percentMissing = 60
            state = SudokuLevel.answerHandler.pickRandomSoln(size: dimension)
            for i in 0..<dimension*dimension*dimension {
                if arc4random_uniform(100) < percentMissing {
                    state[i] = Constants.Colors.clear
                }
            }
        }
    }
    
    func getColour(_ i:Int) -> UIColor {
        return state[i]
    }
    
    func setColor(_ i:Int, colour : UIColor) {
        state[i] = colour
    }
    
    func getDimension() -> Int {
        return dimension
    }
    
    func getSize() -> Int {
        return dimension * dimension * dimension
    }

    func setColor(_ color : UIColor, atIndex index : Int) -> Bool {
        state[index] = color
        // Don't just return hasPassed because allow the ability to re-win level.
        if AnswerHandler.checkAnswer(state,mostRecentIndexChanged: index) {
            hasPassed = true;
            return true;
        }
        return false;
    }
    
    func getHasPassed() -> Bool {
        return hasPassed
    }
    
    func setHasPassed(_ hp : Bool) {
        hasPassed = hp
    }
    
    func getLevelNumber() -> Int {
        return levelNumber
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
        level.setValue(isLocked, forKey: "isLocked")
        let data = SudokuLevel.colorArrayToData(state)
        level.setValue(data, forKey: "state")
        do
        {
            try AppDelegate.context.save()
            print("SAVED")
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
    
    private static func colorArrayToData(_ stateTemp:[UIColor]) -> NSData {
        // Save space by first converting to numeric representation of colors
        var array : [UInt8] = []
        var temp : UInt8?
        for i in 0..<stateTemp.count {
            if i % 2 == 0 {
                temp = SudokuLevel.getColorCode(fromColor: stateTemp[i]) << 4
                // If there are an odd number of cubes.
                if i+1 == stateTemp.count {
                    array.append(temp!)
                }
            }
            else {
                array.append(temp! | (SudokuLevel.getColorCode(fromColor: stateTemp[i]) & 0xf))
                temp = nil
            }
        }
        return NSData(bytes: array, length: array.count)
    }
    
    private static func dataToColorArray(withData data: NSData, arrayLength : Int) -> [UIColor] {
        var stateTemp : [UIColor] = []
        var array : [UInt8] = Array(repeating: 0, count: arrayLength)
        data.getBytes(&array, length:arrayLength)
        for i in 0..<array.count{
            stateTemp.append(SudokuLevel.getColor(storedAsIndex: (array[i] >> 4 ) & 0xf))
            // If not the last elem of an odd dimension cube
            if !((i + 1 == array.count) && (i == 4 || i == 62)) {
                stateTemp.append(SudokuLevel.getColor(storedAsIndex: array[i] & 0xf))
            }
        }
        return stateTemp
    }

    private static func getColorCode(fromColor color: UIColor) -> UInt8 {
        switch color {
        case Constants.Colors.clear:
            return 0
        case Constants.Colors.fill1:
            return 1
        case Constants.Colors.fill1Selected:
            return 2
        case Constants.Colors.fill2:
            return 3
        case Constants.Colors.fill2Selected:
            return 4
        case Constants.Colors.fill3:
            return 5
        case Constants.Colors.fill3Selected:
            return 6
        case Constants.Colors.fill4:
            return 7
        case Constants.Colors.fill4Selected:
            return 8
        case Constants.Colors.fill5:
            return 9
        case Constants.Colors.fill5Selected:
            return 10
        default:
            return 0
        }
    }

    private static func getColor(storedAsIndex index: UInt8) -> UIColor {
        switch index {
        case 0:
            return Constants.Colors.clear
        case 1:
            return Constants.Colors.fill1
        case 2:
            return Constants.Colors.fill1Selected
        case 3:
            return Constants.Colors.fill2
        case 4:
            return Constants.Colors.fill2Selected
        case 5:
            return Constants.Colors.fill3
        case 6:
            return Constants.Colors.fill3Selected
        case 7:
            return Constants.Colors.fill4
        case 8:
            return Constants.Colors.fill4Selected
        case 9:
            return Constants.Colors.fill5
        case 10:
             return Constants.Colors.fill5Selected
        default:
            return Constants.Colors.clear
        }
    }
}
