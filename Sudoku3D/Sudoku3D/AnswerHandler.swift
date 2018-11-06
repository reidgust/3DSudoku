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
    static let referenceArray : [UInt8] = [
    0x1b/*RGBY*/,0x1e/*RGYB*/,0x27/*RBGY*/,0x2d/*RBYG*/,0x36/*RYGB*/,
    0x39/*RYBG*/,0x4b/*GRBY*/,0x4e/*GRYB*/,0x63/*GBRY*/,0x6c/*GBYR*/,
    0x72/*GYRB*/,0x78/*GYBR*/,0x87/*BRGY*/,0x8d/*BRYG*/,0x93/*BGRY*/,
    0x9c/*BGYR*/,0xb1/*BYRG*/,0xb4/*BYGR*/,0xc6/*YRGB*/,0xc9/*YRBG*/,
    0xd2/*YGRB*/,0xd8/*YGBR*/,0xe1/*YBRG*/,0xe4/*YBGR*/]
    
    init(){
        if let path = Bundle.main.path(forResource: "Answers", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
                if let jsonResult = jsonResult as? Dictionary<String, AnyObject>, let person = jsonResult["person"] as? [Any] {
                    // do stuff
                }
            } catch {
                // handle error
            }
        }
    }
    
    static private func checkAnswer(_ ans: [UIColor?]) -> Bool {
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
        
        var rows : [UInt8] = []
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
        
        var searchValue : String = ""
        for i in 0...15 {
            var temp : UInt32 = 0
            if let index = referenceArray.firstIndex(of: rows[i]) {
                let dist : UInt32 = referenceArray.distance(from: referenceArray.startIndex, to: index)
                if i % 2 == 0 {
                    temp = dist << 6
                } else {
                    searchValue.append(String(format:"%03X", (temp | dist)))
                }
            } else { return false }
        }
        
        return true
    }
}
