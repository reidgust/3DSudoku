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
        // Wood
        static let frame = UIColor(red: 50/255, green: 50/255, blue: 50/255, alpha: 1)
        // Gold
        static let frameWon = UIColor(red: 249/255, green: 166/255, blue: 2/255, alpha:1)

        static let clear = UIColor(red: 0, green: 0, blue: 0, alpha: 0)
        
        static let fillColors = [
            UIColor(red: 0, green: 0, blue: 0, alpha: 0),     // CLEAR
            // Chosen Colors
            UIColor(red: 0, green: 0, blue: 1, alpha: 0.8),   // BLUE
            UIColor(red: 1, green: 0, blue: 0, alpha: 0.8),   // RED
            UIColor(red: 0, green: 1, blue: 0.2, alpha: 0.8), // GREEN
            UIColor(red: 0, green: 0.9, blue: 1, alpha: 0.8), // BABY BLUE
            UIColor(red: 1, green: 1, blue: 0, alpha: 0.8),   // YELLOW
            // Given Colors
            UIColor(red: 0, green: 0, blue: 1, alpha: 1),     // BLUE
            UIColor(red: 1, green: 0, blue: 0, alpha: 1),     // RED
            UIColor(red: 0, green: 1, blue: 0.2, alpha: 1),   // GREEN
            UIColor(red: 0, green: 0.9, blue: 1, alpha: 1),   // BABY BLUE
            UIColor(red: 1, green: 1, blue: 0, alpha: 1)]     // YELLOW
        
    }
    
    struct Scripts {
        static let intro = "Hey! Welcome to Sudoku3D! The goal of the game is to make sure each row, each column, and each depth has one of each color. Click on the empty cubes to rotate through the colors. Drag to rotate the cube to make sure you get all of them!"
        static let secondLevel = "The middle square needs to be filled in too. It has been copied down at the bottom. So to fill in the middle square, just click the bottom square."
        static let passedFirstLevel = "Congrats! You passed the first level. Once you pass a level the frame will light up gold. If you want to reset and play again click level 1 at the top. Otherwise, click level 2 to advance in the game."
        static let passed3X3 = "Congrats! You've beat all Size 3 levels! Pro tip: Once you beat the last level of each size (Levels 3, 11, 12), it can be turned into unlimited random levels! Just click the level button at the top."
        static let doneFreeLevels = "You've completed all the free levels. Feel free to play level 3 random levels to your heats content, or click on level 7 to upgrade for more fun!"
        static let upgrade = "Upgrading will give you potential access to all 12 levels including unlimited random levels generated after completing level 4 and 5."
        static let cantPay = "Sorry, your settings don't seem to allow you to purchase the upgrade. Please continue to enjoy the free play."
        static let noProductsAvailable = "Sorry, there seems to be an issue finding the upgrade. Make sure you are connected to the internet, or check back later. Sorry for the inconvenience"
    }
    
    struct AppStore {
        static let ProductShort = "All_Levels"
        static let ProductLong = "com.reidGustavson.Sudoku3D.All_Levels"
        static let BundleID = "com.reidGustavson.Sudoku3D"
    }
    
    static let Levels : [Int : [UInt8]] = [
    1 : [6, 7, 134, 7, 6, 120, 134, 119, 134, 8, 6, 120, 6, 0],
    2 : [104, 120, 6, 118, 135, 104, 96, 120, 118, 135, 103, 8, 104, 112],
    3 : [8, 0, 8, 128, 104, 6, 96, 0, 96, 6, 8, 6, 0, 112],
    4 : [9, 128, 128, 9, 144, 6, 6, 144, 112, 6, 150, 120, 137, 103, 96, 9, 128, 9, 0, 134, 103, 152, 144, 7, 7, 96, 96, 7, 112, 9, 9, 112],
    5 : [144, 6, 7, 96, 9, 128, 112, 8, 6, 144, 105, 135, 135, 105, 8, 112, 9, 96, 152, 118, 118, 152, 7, 128, 96, 9, 6, 144, 8, 112, 128, 7],
    6 : [104, 151, 135, 105, 150, 120, 121, 134, 134, 121, 96, 7, 112, 6, 151, 104, 151, 134, 112, 8, 128, 7, 104, 121, 121, 104, 144, 6, 96, 9, 134, 151],
    7 : [120, 144, 103, 9, 144, 120, 9, 96, 128, 7, 8, 6, 0, 9, 6, 144, 144, 8, 0, 103, 0, 6, 7, 128, 7, 137, 112, 152, 137, 7, 8, 112],
    8 : [0, 0, 150, 112, 96, 128, 8, 144, 152, 118, 96, 7, 112, 144, 128, 105, 112, 9, 128, 0, 152, 103, 96, 0, 0, 144, 120, 9, 9, 0, 144, 128],
    9 : [112, 9, 0, 144, 0, 0, 0, 135, 0, 150, 112, 9, 0, 128, 144, 0, 96, 7, 6, 112, 128, 105, 120, 0, 0, 120, 96, 7, 8, 144, 135, 9],
    10: [0, 128, 96, 0, 137, 0, 118, 0, 134, 0, 0, 8, 96, 128, 8, 0, 9, 8, 128, 0, 0, 6, 103, 0, 8, 112, 0, 128, 118, 144, 128, 7],
    11: [112, 6, 8, 103, 0, 0, 6, 112, 8, 0, 6, 0, 9, 112, 0, 96, 0, 0, 0, 8, 152, 0, 112, 128, 7, 104, 137, 0, 6, 137, 0, 7],
    12: [0, 6, 9, 0, 0, 6, 8, 144, 0, 0, 96, 0, 160, 0, 0, 0, 0, 0, 8, 0, 0, 0, 128, 0, 7, 144, 138, 0, 144, 0, 0, 0, 6, 128, 0, 0, 0, 0, 0, 7, 0, 0, 144, 9, 112, 112, 128, 105, 0, 0, 96, 0, 0, 166, 0, 7, 0, 128, 96, 0, 9, 0, 0]
    ]
}
