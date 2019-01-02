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
    static let innerCubeIndices = [cubeType.InnerThree : [13:0], cubeType.InnerFour : [21:0,22:1,25:2,26:3,37:4,38:5,41:6,42:7], cubeType.InnerFive : [31:0,32:1,33:2,36:3,37:4,38:5,41:6,42:7,43:8,56:9,57:10,58:11,61:12,62:13,63:14,66:15,67:16,68:17,81:18,82:19,83:20,86:21,87:22,88:23,91:24,92:25,93:26], cubeType.InnerInnerFive : [62:0]]
    
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
        var yPos : Float = dimension == 5 ? 2 : 0
        switch type {
        case .Outer:
            break
        case .InnerThree:
            yPos -= 10
        case .InnerFour:
            yPos -= 10
        case .InnerFive:
            yPos -= 7.5
        case .InnerInnerFive:
            yPos -= 13.2
        }
        self.position = SCNVector3(0,yPos,0)
        createAndPlaceCubes()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func update(block: Int, colorIndex: UInt8, status: LevelStatus) {
        if type == cubeType.Outer {cubes[block].setColor(index: colorIndex)}
        else if let newIndex = CubeStructure.innerCubeIndices[type]?[block] {
            cubes[newIndex].setColor(index: colorIndex)
        }
        statusUpdate(status: status)
    }
    
    func statusUpdate(status : LevelStatus) {
        switch status {
        case .wonFirstTime:
            fallthrough
        case .wonAgain:
            self.childNode(withName: "Frame", recursively: true)!.geometry?.firstMaterial?.diffuse.contents = Constants.Colors.frameWon
        case .undidWin:
            fallthrough
        case .normal:
            self.childNode(withName: "Frame", recursively: true)!.geometry?.firstMaterial?.diffuse.contents = Constants.Colors.frame
        }
    }
    
    func update(state: [UInt8], complete: Bool) {
        for i in 0..<state.count {
            if type == cubeType.Outer {cubes[i].setColor(index: state[i])}
            else if let newIndex = CubeStructure.innerCubeIndices[type]?[i] {
                cubes[newIndex].setColor(index: state[i])
            }
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
            let starterCube = Cube(number: 0, numberOfColors: numberOfColors, colorIndex: 0, isComplete: false)
            cubes = Array<Cube>(repeating: starterCube, count: dimension*dimension*dimension)
            for i in 0..<(dimension*dimension*dimension) {
                let cube = Cube(number: i, numberOfColors: numberOfColors, colorIndex: 0, isComplete: false)
                cubes[i] = cube
                cube.position = getCubePosition(index:i)
                self.addChildNode(cube)
            }
        } else {
            cubes = Array<Cube>(repeating: masterCube!.copyCube(0), count: CubeStructure.innerCubeIndices[type]!.count)
            for i in CubeStructure.innerCubeIndices[type]! {
                let cube = masterCube!.copyCube(i.key)
                cube.position = getCubePosition(index:i.key)
                cubes[i.value] = cube
                self.addChildNode(cube)
            }
        }
    }
    
    func copyCube(_ index : Int) -> Cube {
        return cubes[index].copy() as! Cube
    }
}
