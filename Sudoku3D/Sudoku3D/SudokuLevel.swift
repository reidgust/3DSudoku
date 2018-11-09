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
    static let appDelegate = UIApplication.shared.delegate as! AppDelegate
    static let context = appDelegate.persistentContainer.viewContext
    static let answerHander = AnswerHandler()
    var state : [UIColor] = []
    //var colorScheme : [UIColor] = []
    var hasPassed : Bool = false
    var levelNumber : Int
    
    init(level: Int, size: Int, percentMissing: Int) {
        levelNumber = level
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
            if let data = result.value(forKey: "state") as? Data
            {
                self.state = SudokuLevel.binaryToColorArray(withData: data)
            }
            /*if let scheme = result.value(forKey: "colorScheme") as? Int
            {
                self.colorScheme = SudokuLevel.intToScheme(scheme)
            }*/
        }
        else
        {
            state = SudokuLevel.answerHander.pickRandomSoln()
            //colorScheme = Array(state[0...4])
            for i in 0..<size*size*size {
                if arc4random_uniform(100) < percentMissing {
                    state[i] = Constants.Colors.clear
                }
            }
        }
    }
    
    func getColors() -> [UIColor] {
        return state
    }
    
    func setColor(_ color : UIColor, atIndex index : Int) {
        state[index] = color
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
        if let result = getSavedLevel() {
            result.setValue(levelNumber, forKey: "levelNumber")
            result.setValue(hasPassed, forKey: "hasPassed")
            let data = SudokuLevel.colorArrayToBinary(state)
            result.setValue(SudokuLevel.binaryToColorArray(withData: data), forKey: "state")
        }
        else
        {
            let newLevel = NSEntityDescription.insertNewObject(forEntityName: "Level", into: SudokuLevel.context)
            newLevel.setValue(hasPassed, forKey: "hasPassed")
            newLevel.setValue(levelNumber, forKey: "levelNumber")
            let binaryColorArray = SudokuLevel.colorArrayToBinary(state)
            newLevel.setValue(binaryColorArray,forKey:"state")
            do
            {
                try SudokuLevel.context.save()
                print("SAVED")
            }
            catch
            {
                //TODO: Error handling.
            }
        }
    }

    private func getSavedLevel() -> NSManagedObject? {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Level")
        request.returnsObjectsAsFaults = false
        do
        {
            let results = try SudokuLevel.context.fetch(request)
            if results.count < 1 { return nil }
            for result in results as! [NSManagedObject] {
                if result.value(forKey: "levelNumber") as? Int == levelNumber { return result }
            }
            return nil
        }
        catch
        {
            return nil
        }
    }

    /*private static func colorArrayToInt(_ schemeTemp:[UIColor]) -> Int {
        return 0
    }*/
    
    private static func colorArrayToBinary(_ stateTemp:[UIColor]) -> Data {
        var array : [Int] = []
        var temp : Int?
        for i in 0..<stateTemp.count {
            if i % 2 == 0 { temp = SudokuLevel.getColorCode(fromColor: stateTemp[i]) << 4}
            else {
                array[i/2] = (temp! | (SudokuLevel.getColorCode(fromColor: stateTemp[i]) & 0xff))
                temp = nil
            }
        }
        if let temp = temp {
            array[stateTemp.count/2 + 1] = temp | 0xff
        }
        return NSKeyedArchiver.archivedData(withRootObject: array)
    }
    
    private static func getColorCode(fromColor color: UIColor) -> Int {
        switch color {
        case Constants.Colors.fill1:
            return 0
        case Constants.Colors.fill2:
            return 1
        case Constants.Colors.fill3:
            return 2
        case Constants.Colors.fill4:
            return 3
        case Constants.Colors.fill5:
            return 4
        case Constants.Colors.clear:
            return 5
        case Constants.Colors.fill1Selected:
            return 6
        case Constants.Colors.fill2Selected:
            return 7
        case Constants.Colors.fill3Selected:
            return 8
        case Constants.Colors.fill4Selected:
            return 9
        case Constants.Colors.fill5Selected:
            return 10
        default:
            return 15
        }
    }

    /*private static func intToScheme(_ val : Int) -> [UIColor] {
        return []
    }*/
    
    private static func binaryToColorArray(withData data: Data) -> [UIColor]{
        var stateTemp : [UIColor] = []
        let array = NSKeyedUnarchiver.unarchiveObject(with: data)
        for elem in (array as! [Int?]){
            stateTemp.append(SudokuLevel.getColor(storedAsIndex: elem!>>4)!)
            if let val = SudokuLevel.getColor(storedAsIndex: elem! & 0xff){
                stateTemp.append(val)
            }
        }
        return stateTemp
    }
    
    private static func getColor(storedAsIndex index: Int) -> UIColor?{
        switch index {
        case 0:
            return Constants.Colors.fill1
        case 1:
            return Constants.Colors.fill2
        case 2:
            return Constants.Colors.fill3
        case 3:
            return Constants.Colors.fill4
        case 4:
            return Constants.Colors.fill5
        case 5:
            return Constants.Colors.clear
        case 6:
            return Constants.Colors.fill1Selected
        case 7:
            return Constants.Colors.fill2Selected
        case 8:
            return Constants.Colors.fill3Selected
        case 9:
            return Constants.Colors.fill4Selected
        case 10:
            return Constants.Colors.fill5Selected
        default:
            return nil
        }
    }
}
