//
//  CubeStructure.swift
//  Sudoku3D
//
//  Created by Reid on 2019-01-01.
//  Copyright © 2019 Reid. All rights reserved.
//

import Foundation
import SceneKit

class CubeStructure : SCNNode, LevelObserver{
    var id: Int

    enum cubeType {
        case Outer
        case InnerThree
        case InnerFour
        case InnerFive
        case InnerInnerFive
    }

    let type : cubeType
    let delegate : GameViewController
    var masterCube : CubeStructure?
    var numberOfColors : Int
    var dimension : Int
    var cubes : [Cube] = []
    static let innerCubeIndices = [cubeType.InnerThree : [13], cubeType.InnerFour : [21,22,25,26,37,38,41,42], cubeType.InnerFive : [31,32,33,36,37,38,41,42,43,56,57,58,61,62,63,66,67,68,81,82,83,86,87,88,91,92,93], cubeType.InnerInnerFive : [62]]
    
    init(numberOfColors : Int, dimension : Int, delegate : GameViewController, masterCube : CubeStructure? = nil) {
        self.numberOfColors = numberOfColors
        self.delegate = delegate
        self.dimension = dimension
        self.masterCube = masterCube
        self.id = (dimension * 10) + numberOfColors
        type = numberOfColors == dimension ? .Outer : (numberOfColors == 3 ? .InnerThree : (numberOfColors == 4 ? .InnerFour : (dimension == 1 ? .InnerInnerFive : .InnerFive)))
        super.init()
        self.geometry = SCNBox(width: 0, height: 0, length: 0, chamferRadius: 0)
        self.geometry?.firstMaterial?.diffuse.contents = Constants.Colors.clear
        self.light = SCNLight()
        self.light!.type = SCNLight.LightType.ambient
        self.light!.temperature = 500
        self.light!.intensity = 500
        self.name = "structureSized\(dimension)"
        var yPos = dimension == 5 ? 2 : 0
        switch type {
        case .Outer:
            break
        case .InnerThree:
            yPos -= 10
        case .InnerFour:
            yPos -= 10
        case .InnerFive:
            yPos -= 10
        case .InnerInnerFive:
            yPos -= 17
        }
        self.position = SCNVector3(0,yPos,0)
        createAndPlaceCubes()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func update(block: Int, colorIndex: UInt8, status: LevelStatus) {
        cubes[block].setColor(index: colorIndex)
        statusUpdate(status: status)
    }
    
    func statusUpdate(status : LevelStatus) {
        switch status {
        case .wonFirstTime:
            fallthrough
        case .wonAgain:
            self.childNode(withName: "Frame1", recursively: true)!.geometry?.firstMaterial?.diffuse.contents = Constants.Colors.frameWon
        case .undidWin:
            fallthrough
        case .normal:
            self.childNode(withName: "Frame1", recursively: true)!.geometry?.firstMaterial?.diffuse.contents = Constants.Colors.frame
        }
    }
    
    func update(state: [UInt8], complete: Bool) {
        for i in 0..<state.count {
            cubes[i].setColor(index: state[i])
        }
        if complete {statusUpdate(status: .wonAgain)}
        else {statusUpdate(status: .normal)}
    }
    
    func updateAngles(x:Float,y:Float){
        self.eulerAngles.x = x
        self.eulerAngles.y = y
    }
    
    func getCubePosition(index i: Int) -> SCNVector3{
        let scale : Float = numberOfColors == 5 ? 1.5 : 2
        let offset = (Float(numberOfColors) / 2) - 0.5
        let position = SCNVector3(
            x: (Float(i % numberOfColors) - offset) * scale,
            y: ((Float((i / numberOfColors) % numberOfColors)) - offset) * scale,
            z: ((Float(((i / (numberOfColors*numberOfColors)) % numberOfColors)) - offset) * scale))
        return position
    }

    func createAndPlaceCubes(){
        if type == CubeStructure.cubeType.Outer {
            for i in 0..<Int(pow(Double(dimension),3.0)) {
                let cube = Cube(number: i, numberOfColors: numberOfColors, colorIndex: 0, isComplete: false)
                cubes.append(cube)
                cube.position = getCubePosition(index:i)
                self.addChildNode(cube)
            }
        } else {
            for i in CubeStructure.innerCubeIndices[type]! {
                let cube = masterCube!.copyCube(i)
                //cubes.append(cube)
                //cube.position = getCubePosition(index:i)
                self.addChildNode(cube)
            }
        }
    }
    
    func copyCube(_ index : Int) -> Cube {
        return cubes[index].copy() as! Cube
    }

    /*func removeCubes(oldSize: Int) {
        for node in self.childNodes {
            node.removeFromParentNode()
        }
    }*/
}
