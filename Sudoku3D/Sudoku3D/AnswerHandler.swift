//
//  AnswerHandler.swift
//  Sudoku3D
//
//  Created by Reid on 2018-11-06.
//  Copyright © 2018 Reid. All rights reserved.
//

import Foundation
import UIKit

class AnswerHandler {
    let validAnswers : [[UInt32]]
    static var proposedAnswer: [UIColor?] = []
    static var proposedDimension: Int = 0
    var searchValue : [UInt32] = [0,0,0,0]

    init(){
        if let path = Bundle.main.path(forResource: "AnswersSimple", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                validAnswers = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves) as! Array<Array<UInt32>>
            } catch {
                fatalError("Can't load answer set.")
            }
        } else {
            fatalError("Can't find answer set.")
        }
    }
    
    public func pickRandomSoln(size dimension: Int) -> [UIColor] {
        var randVal : [UInt32] = []
        var numBits = 0
        switch dimension {
        case 2:
            randVal = [0x96000000]
            numBits = 1
        case 3:
            randVal = validAnswers[Int(arc4random_uniform(UInt32(validAnswers.count)))]
            numBits = 2
        case 4:
            randVal = validAnswers[Int(arc4random_uniform(UInt32(validAnswers.count)))]
            numBits = 2
        case 5:
            randVal = validAnswers[Int(arc4random_uniform(UInt32(validAnswers.count)))]
            numBits = 4
        default:
            fatalError("Invalid Cube Dimension requested")
        }
        
        var refCols : [UIColor] = []
        var solnCols : [UIColor] = []
        var colChoices = [Constants.Colors.fill1, Constants.Colors.fill2, Constants.Colors.fill3, Constants.Colors.fill4,Constants.Colors.fill5]
        colChoices = Array(colChoices[0..<dimension])
        for _ in 0..<dimension {
            let index = arc4random_uniform(UInt32(colChoices.count))
            refCols.append(colChoices.remove(at: Int(index)))
        }
        var val : UInt32 = 0
        let numCols = 32/numBits
        for i in 0..<Int(pow(Double(dimension),3.0)) {
            let row = i / numCols
            let col = i % numCols
            if col == 0 { val = randVal[row]}
            
            let index = Int(val >> ((numCols - col - 1) * numBits)) & Int(pow(Double(numBits),2.0) - 1)
            solnCols.append(refCols[index])
        }
        return solnCols
    }
    
    private static func getColorIndex(_ color:UIColor) -> Int {
        switch color {
        case Constants.Colors.fill1,Constants.Colors.fill1Selected:
            return 0
        case Constants.Colors.fill2,Constants.Colors.fill2Selected:
            return 1
        case Constants.Colors.fill3,Constants.Colors.fill3Selected:
            return 2
        case Constants.Colors.fill4,Constants.Colors.fill4Selected:
            return 3
        case Constants.Colors.fill5,Constants.Colors.fill5Selected:
            return 4
        default:
            return -1
        }
    }
    
    private static func checkIndex(_ i:Int) ->Bool {
        // Check the columns
        let dim = proposedDimension
        let dim2 = proposedDimension * proposedDimension
        var j : Int = (i/dim) * dim
        for j in (i/dim)*dim..<(((i/dim)*dim)+dim) {
            if j == i {break}
            if getColorIndex(proposedAnswer[i]!) == getColorIndex(proposedAnswer[j]!) {return false}
        }
        // Check the rows
        for k in 0..<dim {
            j = (i % dim) + (i/dim2) * dim2 + dim * k
            if j == i {break}
            if getColorIndex(proposedAnswer[i]!) == getColorIndex(proposedAnswer[j]!) {return false}
        }
        // Check the depths
        for k in 0..<dim {
            j = (i % dim2) + dim2 * k
            if j == i {break}
            if getColorIndex(proposedAnswer[i]!) == getColorIndex(proposedAnswer[j]!) {return false}
        }
        return true
    }
    
    public static func checkAnswer(_ ans: [UIColor?],mostRecentIndexChanged index: Int) -> Bool {
        if ans.contains(Constants.Colors.clear) { return false }
        proposedAnswer = ans;
        proposedDimension = ans.count == 27 ? 3 : (ans.count == 64 ? 4 : 5)
        // First check the cube most recently changed
        if !checkIndex(index) {return false}
        for i in 0..<ans.count{
            if i == index {continue}
            if !checkIndex(i) {return false}
        }
        return true
    }
    
    private func searchValidAnswers(for searchVal: [UInt32]) -> Bool {
        var low = 0
        var high = validAnswers.count - 1
        var mid = Int(high / 2)
        
        while low <= high {
            let midElement = validAnswers[mid]
            switch compareValues(midElement) {
            case -1 :
                high = mid - 1
            case 0:
                return true
            case 1:
                low = mid + 1
            default:
                return false
            }
            mid = (low + high) / 2
        }
        
        return false
    }
    
    private func compareValues(_ levelTerm : [UInt32]) ->Int8 {
        for i in 0...3 {
            if(levelTerm[i] > searchValue[i]) {return -1}
            if(levelTerm[i] < searchValue[i]) {return 1}
        }
        return 0;
    }
}
