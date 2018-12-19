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
    static let colorChoices = [Constants.Colors.fill1, Constants.Colors.fill2, Constants.Colors.fill3, Constants.Colors.fill4,Constants.Colors.fill5]
    static let validAnswers3 : [[UInt32]] = [[26145,100422,135576],[26145,135576,100422],[26712,98721,136710],[26712,136710,98721]]
    static var validAnswers4 : [[UInt32]] = []
    static var validAnswers5 : [[UInt16]] = []
    static var proposedAnswer: [UIColor?] = []
    static var proposedDimension: Int = 0
    
    public func pickRandomSoln(size dimension: Int) -> [UIColor] {
        // Randomize color choices otherwise first column will always be the same, as it is the reference column.
        var refCols : [UIColor] = []
        var solnCols : [UIColor] = []
        var colChoices = Array(AnswerHandler.colorChoices[0..<dimension])
        for _ in 0..<dimension {
            let index = arc4random_uniform(UInt32(colChoices.count))
            refCols.append(colChoices.remove(at: Int(index)))
        }
        // Number of bits to encode each color value
        var numBits = 0
        var randVal : [UInt32] = []
        
        switch dimension {
        case 2:
            // Simple 2x2 Only used for tutorial level.
            return [Constants.Colors.fill1,Constants.Colors.fill2,Constants.Colors.fill2,Constants.Colors.clear,
                Constants.Colors.fill2,Constants.Colors.fill1,Constants.Colors.clear,Constants.Colors.clear]
        case 3:
            randVal = AnswerHandler.validAnswers3[Int(arc4random_uniform(UInt32(4)))];
            numBits = 2
        case 4:
            if AnswerHandler.validAnswers4.count == 0 {AnswerHandler.loadAnswers(dim:4)}
            randVal = AnswerHandler.validAnswers4[Int(arc4random_uniform(UInt32(AnswerHandler.validAnswers4.count)))]
            numBits = 2
        case 5:
            if AnswerHandler.validAnswers5.count == 0 {AnswerHandler.loadAnswers(dim:5)}
            let rand = AnswerHandler.validAnswers5[Int(arc4random_uniform(UInt32(AnswerHandler.validAnswers5.count)))]
            for col in 0..<25 {
                let val = rand[col]
                for row in 0..<5 {
                    let index = Int((val >> ((4-row) * 3)) & UInt16(0x7))
                    solnCols.append(refCols[index])
                }
            }
            return solnCols
        default:
            fatalError("Invalid Cube Dimension requested")
        }
        
        var val : UInt32 = 0
        let numCols = dimension * dimension
        for i in 0..<Int(pow(Double(dimension),3.0)) {
            let col = i / numCols
            let row = i % numCols
            if row == 0 { val = randVal[col]}

            let index = Int(val >> ((numCols - row - 1) * numBits)) & Int(pow(Double(numBits),2.0) - 1)
            solnCols.append(refCols[index])
        }
        return solnCols
    }
    
    private static func loadAnswers(dim: Int) {
        let resourceName : String = "Answers\(dim)"
        if let path = Bundle.main.path(forResource: resourceName, ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                switch dim {
                case 4:
                    validAnswers4 = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves) as! Array<Array<UInt32>>
                case 5:
                    validAnswers5 = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves) as! Array<Array<UInt16>>
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
}
