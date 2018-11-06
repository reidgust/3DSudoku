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
    
    public func pickRandomSoln() -> [UIColor] {
        let randVal : [UInt32]  = validAnswers[Int(arc4random_uniform(UInt32(validAnswers.count)))]
        var refCols : [UIColor] = []
        var solnCols : [UIColor] = []
        var colChoices = [Constants.Colors.fill1, Constants.Colors.fill2, Constants.Colors.fill3, Constants.Colors.fill4]
        for _ in 0...3 {
            let index = arc4random_uniform(UInt32(colChoices.count))
            refCols.append(colChoices.remove(at: Int(index)))
        }
        for currentInt in randVal {
            for j in 0...15 {
                solnCols.append(refCols[Int(currentInt >> (j * 2)) & 3])
            }
        }
        return solnCols
    }

    private func checkAnswer(_ ans: [UIColor?]) -> Bool {
        if ans.contains(nil) { return false }
        var refCols : [UIColor] = []
        for i in 0...3 {
            switch ans[i] {
            case Constants.Colors.fill1,Constants.Colors.fill1Selected:
                refCols.append(Constants.Colors.fill1)
                refCols.append(Constants.Colors.fill1Selected)
            case Constants.Colors.fill2,Constants.Colors.fill2Selected:
                refCols.append(Constants.Colors.fill2)
                refCols.append(Constants.Colors.fill2Selected)
            case Constants.Colors.fill3,Constants.Colors.fill3Selected:
                refCols.append(Constants.Colors.fill3)
                refCols.append(Constants.Colors.fill3Selected)
            case Constants.Colors.fill4,Constants.Colors.fill4Selected:
                refCols.append(Constants.Colors.fill4)
                refCols.append(Constants.Colors.fill4Selected)
            default:
                return false
            }
        }
        if (!refCols.contains(Constants.Colors.fill1) ||
            !refCols.contains(Constants.Colors.fill2) ||
            !refCols.contains(Constants.Colors.fill3) ||
            !refCols.contains(Constants.Colors.fill4)) {
            return false
        }
        
        var rows : [UInt32] = []
        for i in 0...63 {
            switch ans[i] {
            case refCols[0],refCols[1]:
                if i % 4 == 0 { rows[i/4] = 0}
            case refCols[2],refCols[3]:
                if i % 4 == 0 { rows[i%4] = 0x40}
                else {rows[i/4] = rows[i/4] & (1 << ((3 - (i % 4)) * 2)) }
            case refCols[4],refCols[5]:
                if i % 4 == 0 { rows[i%4] = 0x80}
                else {rows[i/4] = rows[i/4] & (2 << ((3 - (i % 4)) * 2)) }
            case refCols[6],refCols[7]:
                if i % 4 == 0 { rows[i%4] = 0xc0}
                else {rows[i/4] = rows[i/4] & (3 << ((3 - (i % 4)) * 2)) }
            default:
                return false
            }
        }
        
        searchValue = [0,0,0,0]
        var temp : UInt32 = 0
        for i in 0...15 {
            if i % 4 == 0 { temp = 0 }
            temp = temp | (rows[i]  << ((3 - (i % 4)) * 8))
            if i % 4 == 3 { searchValue[i/4] = temp }
        }
        
        return searchValidAnswers(for:searchValue)
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
