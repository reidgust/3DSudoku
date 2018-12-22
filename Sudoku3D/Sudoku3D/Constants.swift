//
//  Constants.swift
//  Sudoku3D
//
//  Created by Reid on 2018-11-03.
//  Copyright © 2018 Reid. All rights reserved.
//

import Foundation
import UIKit

struct Constants {
    struct Colors {
        // Purple 7204D9
        static let title = UIColor(red: 114/255, green: 4/255, blue: 217/255, alpha: 1)
        // Grey
        static let selected = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1)
        // Wood
        static let frame = UIColor(red: 50/255, green: 50/255, blue: 50/255, alpha: 1)
        // Gold
        static let frameWon = UIColor(red: 249/255, green: 166/255, blue: 2/255, alpha:1)
        // Blue
        static let fill1 = UIColor(red: 0, green: 0, blue: 1, alpha: 1)
        static let fill1Selected = UIColor(red: 0, green: 0, blue: 1, alpha: 0.8)
        // Red
        static let fill2 = UIColor(red: 1, green: 0, blue: 0, alpha: 1)
        static let fill2Selected = UIColor(red: 1, green: 0, blue: 0, alpha: 0.8)
        // Green
        static let fill3 = UIColor(red: 0, green: 1, blue: 0.2, alpha: 1)
        static let fill3Selected = UIColor(red: 0, green: 1, blue: 0.2, alpha: 0.8)
        // Baby Blue
        static let fill4 = UIColor(red: 0, green: 0.9, blue: 1, alpha: 1)
        static let fill4Selected = UIColor(red: 0, green: 0.9, blue: 1, alpha: 0.8)
        // Yellow
        static let fill5 = UIColor(red: 1, green: 1, blue: 0, alpha: 1)
        static let fill5Selected = UIColor(red: 1, green: 1, blue: 0, alpha: 0.8)
        // Clear
        static let clear = UIColor(red: 0, green: 0, blue: 0, alpha: 0)
    }
    
    static let Levels : [Int : [UInt8]] = [
    1 : [1, 3, 81, 3, 1, 53, 81, 51, 81, 5, 1, 53, 1, 0],
    2 : [21, 53, 1, 49, 83, 21, 16, 53, 49, 83, 19, 5, 21, 48],
    3 : [5, 0, 5, 80, 21, 1, 16, 0, 16, 1, 5, 1, 0, 48],
    4 : [7, 80, 80, 7, 112, 1, 1, 112, 48, 1, 113, 53, 87, 19, 16, 7, 80, 7, 55, 81, 19, 117, 112, 3, 3, 16, 16, 3, 48, 7, 7, 48],
    5 : [112, 1, 3, 16, 7, 80, 48, 5, 1, 112, 23, 83, 83, 23, 5, 48, 7, 16, 117, 49, 49, 117, 3, 80, 16, 7, 1, 112, 5, 48, 80, 3],
    6 : [21, 115, 83, 23, 113, 53, 55, 81, 81, 55, 16, 3, 48, 1, 115, 21, 115, 81, 48, 5, 80, 3, 21, 55, 55, 21, 112, 1, 16, 7, 81, 115],
    7 : [53, 112, 19, 7, 112, 53, 7, 16, 80, 3, 5, 1, 0, 7, 1, 112, 112, 5, 0, 19, 0, 1, 3, 80, 3, 87, 48, 117, 87, 3, 5, 48],
    8 : [0, 0, 113, 48, 16, 80, 5, 112, 117, 49, 16, 3, 48, 112, 80, 23, 48, 7, 80, 0, 117, 19, 16, 0, 0, 112, 53, 7, 7, 0, 112, 80],
    9 : [48, 7, 0, 112, 0, 0, 0, 83, 0, 113, 48, 7, 0, 80, 112, 0, 16, 3, 1, 48, 80, 23, 53, 0, 0, 53, 16, 3, 5, 112, 83, 7],
    10: [0, 80, 16, 0, 87, 0, 49, 0, 81, 0, 0, 5, 16, 80, 5, 0, 7, 5, 80, 0, 0, 1, 19, 0, 5, 48, 0, 80, 49, 112, 80, 3],
    11: [48, 1, 5, 19, 0, 0, 1, 48, 5, 0, 1, 0, 7, 48, 0, 16, 0, 0, 0, 5, 117, 0, 48, 80, 3, 21, 87, 0, 1, 87, 0, 3],
    12: [0, 1, 7, 0, 0, 1, 5, 112, 0, 0, 16, 0, 144, 0, 0, 0, 0, 0, 5, 0, 0, 0, 80, 0, 3, 112, 89, 0, 112, 0, 0, 0, 1, 80, 0, 0, 0, 0, 0, 3, 0, 0, 112, 7, 48, 48, 80, 23, 0, 0, 16, 0, 0, 145, 0, 3, 0, 80, 16, 0, 7, 0, 0]
    ]
}
