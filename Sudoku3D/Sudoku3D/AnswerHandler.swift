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
    static var validAnswers4 : [[UInt32]] = []
    static var validAnswers5 : [[UInt32]] = []
    static var proposedAnswer: [UIColor?] = []
    static var proposedDimension: Int = 0
    static let colorChoices = [Constants.Colors.fill1, Constants.Colors.fill2, Constants.Colors.fill3, Constants.Colors.fill4,Constants.Colors.fill5]
    var searchValue : [UInt32] = [0,0,0,0]

    init(){
        if AnswerHandler.validAnswers4.count == 0 {AnswerHandler.loadAnswers(dim:4)}
    }
    
    public func pickRandomSoln(size dimension: Int) -> [UIColor] {
        var randVal : [UInt32] = []
        var numBits = 0
        switch dimension {
        case 2:
            // Simple 2x2 Only used for tutorial level.
            return [Constants.Colors.fill1,Constants.Colors.fill2,Constants.Colors.fill2,Constants.Colors.clear,
                Constants.Colors.fill2,Constants.Colors.fill1,Constants.Colors.clear,Constants.Colors.clear]
        case 3:
            // TODO: Placeholder text, not correct.
            return [Constants.Colors.fill1,Constants.Colors.fill2,Constants.Colors.clear,
                       Constants.Colors.fill3,Constants.Colors.fill1,Constants.Colors.clear,
                       Constants.Colors.fill2,Constants.Colors.clear,Constants.Colors.clear,
                       Constants.Colors.fill2,Constants.Colors.clear,Constants.Colors.clear,
                       Constants.Colors.clear,Constants.Colors.clear,Constants.Colors.clear,
                       Constants.Colors.clear,Constants.Colors.fill1,Constants.Colors.clear,
                       Constants.Colors.clear,Constants.Colors.clear,Constants.Colors.clear,
                       Constants.Colors.clear,Constants.Colors.clear,Constants.Colors.clear,
                       Constants.Colors.clear,Constants.Colors.clear,Constants.Colors.fill2]
            //numBits = 2
        case 4:
            if AnswerHandler.validAnswers4.count == 0 {AnswerHandler.loadAnswers(dim:4)}
            randVal = AnswerHandler.validAnswers4[Int(arc4random_uniform(UInt32(AnswerHandler.validAnswers4.count)))]
            numBits = 2
        case 5:
            // TODO: Placeholder text, don't think 4 & 5 are same encoding.
            if AnswerHandler.validAnswers5.count == 0 {AnswerHandler.loadAnswers(dim:5)}
            randVal = AnswerHandler.validAnswers5[Int(arc4random_uniform(UInt32(AnswerHandler.validAnswers5.count)))]
            numBits = 3
        default:
            fatalError("Invalid Cube Dimension requested")
        }
        
        var refCols : [UIColor] = []
        var solnCols : [UIColor] = []
        var colChoices = Array(AnswerHandler.colorChoices[0..<dimension])
        for _ in 0..<dimension {
            let index = arc4random_uniform(UInt32(colChoices.count))
            refCols.append(colChoices.remove(at: Int(index)))
        }
        var val : UInt32 = 0
        let numCols = dimension * dimension
        for i in 0..<Int(pow(Double(dimension),3.0)) {
            let row = i / numCols
            let col = i % numCols
            if col == 0 { val = randVal[row]}
            
            // This math will need to be changed per dimension
            let index = Int(val >> ((numCols - col - 1) * numBits)) & Int(pow(Double(numBits),2.0) - 1)
            solnCols.append(refCols[index])
        }
        return solnCols
    }
    
    private static func loadAnswers(dim: Int) {
        var resourceName : String
        switch dim {
        case 3:
            // TODO: Make 3X3 answer set.
            resourceName = "AnswersSimple"
        case 4:
            resourceName = "AnswersSimple"
        case 5:
            resourceName = "Answers5"
        default:
            fatalError("No answer set for that dimension value")
        }
        if let path = Bundle.main.path(forResource: resourceName, ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                switch dim {
                case 3:
                    //TODO: Placeholder Text. Make 3X3 answers.
                    validAnswers4 = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves) as! Array<Array<UInt32>>
                case 4:
                    validAnswers4 = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves) as! Array<Array<UInt32>>
                case 5:
                    validAnswers5 = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves) as! Array<Array<UInt32>>
                default:
                    fatalError("No answer set for that dimension value")
                }
                
            } catch {
                fatalError("Can't load answer set.")
            }
        } else {
            fatalError("Can't find answer set.")
        }
    }
    
    // Helper function for check Index, which is only called if there are no Clear cubes.
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
        let dim = proposedDimension
        let dim2 = proposedDimension * proposedDimension
        // Check the columns
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
        var high = AnswerHandler.validAnswers4.count - 1
        var mid = Int(high / 2)
        
        while low <= high {
            let midElement = AnswerHandler.validAnswers4[mid]
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
