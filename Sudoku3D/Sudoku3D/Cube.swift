//
//  Cube.swift
//  Sudoku3D
//
//  Created by Reid on 2019-01-01.
//  Copyright © 2019 Reid. All rights reserved.
//

import Foundation
import SceneKit

class Cube : SCNNode {

    static let theFrameArt = SCNScene(named: "art.scnassets/Set.dae")!.rootNode.childNode(withName: "Frame", recursively: true)!
    static let theCubeArt = SCNScene(named: "art.scnassets/Set.dae")!.rootNode.childNode(withName: "Cube", recursively: true)!
    let cubeNumber : Int
    let numberOfColors : Int
    var colorIndex : UInt8
    var width : Float

    var cubeNode : SCNNode
    var frameNode : SCNNode
    
    init(number : Int, numberOfColors : Int, colorIndex : UInt8, isComplete : Bool, width : Float) {
        cubeNumber = number
        self.width = width
        self.numberOfColors = numberOfColors
        self.colorIndex = colorIndex
        let cubeGeometry = Cube.theCubeArt.geometry
        let frameGeometry = Cube.theFrameArt.geometry
        cubeNode = SCNNode(geometry: cubeGeometry!.copy() as? SCNGeometry)
        frameNode = SCNNode(geometry: frameGeometry!.copy() as? SCNGeometry)
        cubeNode.name = "Cube\(cubeNumber)"
        frameNode.name = "Frame"
        cubeNode.scale = SCNVector3Make(width, width, width)
        frameNode.scale = SCNVector3Make(width/2, width/2, width/2)
        cubeNode.geometry?.firstMaterial = SCNMaterial()
        cubeNode.geometry?.firstMaterial?.diffuse.contents = Constants.Colors.fillColors[Int(colorIndex)]
        frameNode.geometry?.firstMaterial?.diffuse.contents = isComplete ? Constants.Colors.frameWon : Constants.Colors.frame
        super.init()
        self.addChildNode(cubeNode)
        self.addChildNode(frameNode)
        self.name = "Block\(cubeNumber)"
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func copy(with zone: NSZone? = nil) -> Any {
        let cc = Cube(number: self.cubeNumber, numberOfColors: self.numberOfColors, colorIndex: self.colorIndex, isComplete: self.frameNode.geometry?.firstMaterial?.diffuse.contents as! UIColor == Constants.Colors.frameWon, width : self.width)
        return cc
    }
    
    func setColor(index : UInt8) {
        colorIndex = index
        cubeNode.geometry?.firstMaterial?.diffuse.contents = Constants.Colors.fillColors[Int(colorIndex)]
    }

    func getCubeNumber() -> Int {
        return cubeNumber
    }
}
