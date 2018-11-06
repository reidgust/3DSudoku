//
//  GameViewController.swift
//  Sudoku3D
//
//  Created by Reid on 2018-11-02.
//  Copyright © 2018 Reid. All rights reserved.
//

import UIKit
import QuartzCore
import SceneKit

class GameViewController: UIViewController {

    var gameView : SCNView!
    var gameScene : SCNScene!
    var cameraNode : SCNNode!
    var targetCreationTime : TimeInterval = 0
    var nodeColors : [UIColor?] = Array(repeating: nil, count: 64)
    let activeNodeMaterials = makeNodeMaterials()
    let answerHander = AnswerHandler()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initView()
        initScene()
        initCamera()
        createGameObjects()
    }
    
    static func makeNodeMaterials() -> [SCNMaterial] {
        var materials : [SCNMaterial] = []
        let material1 = SCNMaterial()
        material1.diffuse.contents = Constants.Colors.clear
        materials.append(material1)
        let material2 = SCNMaterial()
        material2.diffuse.contents = Constants.Colors.fill1Selected
        materials.append(material2)
        let material3 = SCNMaterial()
        material3.diffuse.contents = Constants.Colors.fill2Selected
        materials.append(material3)
        let material4 = SCNMaterial()
        material4.diffuse.contents = Constants.Colors.fill3Selected
        materials.append(material4)
        let material5 = SCNMaterial()
        material5.diffuse.contents = Constants.Colors.fill4Selected
        materials.append(material5)
        return materials
    }
    
    static func makeAnswerNodeMaterial(forColor color: UIColor) -> SCNMaterial {
        let material2 = SCNMaterial()
        material2.diffuse.contents = color
        return material2
    }
    
    func initView() {
        gameView = self.view as? SCNView
        gameView.allowsCameraControl = true
        gameView.autoenablesDefaultLighting = true
    }
    
    func initScene() {
        gameScene = SCNScene()
        gameView.scene = gameScene
        gameView.isPlaying = true
    }
    
    func initCamera() {
        cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3(0, 0, 50)
        gameScene.rootNode.addChildNode(cameraNode)
    }
    
    func createGameObjects() {
        let sceneObjects = SCNScene(named: "art.scnassets/Set.dae")!
        let title = SCNScene(named: "art.scnassets/Title.dae")!
        let frame = sceneObjects.rootNode.childNode(withName: "Frame", recursively: true)
        let cube = sceneObjects.rootNode.childNode(withName: "Cube", recursively: true)
        nodeColors = answerHander.pickRandomSoln()
        var materials : [UIColor:SCNMaterial] = [:]
        for i in 0...3 {
            materials[nodeColors[i]!] = GameViewController.makeAnswerNodeMaterial(forColor:nodeColors[i]!)
        }
        
        if let geometry = title.rootNode.childNode(withName: "typeMesh1", recursively: true)?.geometry {
            let titleNode = SCNNode(geometry: geometry)
            titleNode.scale = SCNVector3Make(0.5, 0.5, 0.5)
            titleNode.position = SCNVector3(x: -14 , y: 10, z: -20)
            titleNode.name = "Title"
            let newMaterial2 = SCNMaterial()
            newMaterial2.diffuse.contents = Constants.Colors.title
            titleNode.geometry?.firstMaterial = newMaterial2
            gameScene.rootNode.addChildNode(titleNode)
        }
        
        if let boxGeometry = cube?.geometry {
            for i in 0..<64 {
                let geometry = boxGeometry.copy() as! SCNGeometry
                let cubeNode = SCNNode(geometry: geometry)
                cubeNode.name = "Cube\(i)"
                cubeNode.scale = SCNVector3Make(2, 2, 2)
                cubeNode.position = SCNVector3(x: Float(i%4)*2 - 4, y: Float((i/4)%4)*2 - 10, z: Float((i/16)%4)*2 - 16)
                cubeNode.geometry?.firstMaterial = arc4random_uniform(64) < 20 ?  materials[nodeColors[i]!] : activeNodeMaterials[0]
                if (i%4 == 1 || i%4 == 2) && ((i/4)%4 == 1 || (i/4)%4 == 2) && ((i/16)%4 == 1 || (i/16)%4 == 2)  {
                    let innerCubePiece = cubeNode.copy() as! SCNNode
                    innerCubePiece.position = SCNVector3(x: Float(i%4)*2 + 4, y: Float((i/4)%4)*2 - 2, z: Float((i/16)%4)*2 - 24)
                    gameScene.rootNode.addChildNode(innerCubePiece)
                }
                gameScene.rootNode.addChildNode(cubeNode)
            }
        }
        
        if let boxGeometry = frame?.geometry {
            let newMaterial = SCNMaterial()
            newMaterial.diffuse.contents = Constants.Colors.frame
            for i in 0..<64 {
                let frameNode = SCNNode(geometry: boxGeometry)
                frameNode.name = "Frame"
                frameNode.scale = SCNVector3Make(1, 1, 1)
                frameNode.position = SCNVector3(x: Float(i%4)*2 - 4, y: Float((i/4)%4)*2 - 10, z: Float((i/16)%4)*2 - 16)
                frameNode.geometry?.firstMaterial = newMaterial
                if (i%4 == 1 || i%4 == 2) && ((i/4)%4 == 1 || (i/4)%4 == 2) && ((i/16)%4 == 1 || (i/16)%4 == 2)  {
                    let innerCubePiece = frameNode.copy() as! SCNNode
                    innerCubePiece.position = SCNVector3(x: Float(i%4)*2 + 4, y: Float((i/4)%4)*2 - 2, z: Float((i/16)%4)*2 - 24)
                    gameScene.rootNode.addChildNode(innerCubePiece)
                }
                gameScene.rootNode.addChildNode(frameNode)
            }
        }
    }
    
    func nextColor(forNode node: SCNNode) {
        if !(node.name?.contains("Cube"))! { return }
        let nodeIndex = Int(node.name![node.name!.index(node.name!.startIndex, offsetBy: 4)...])
        if let material : SCNMaterial = node.geometry?.firstMaterial {
            if let i : Int = activeNodeMaterials.firstIndex(of: material)
            {
                if i > -1 {
                    let newIndex = (i + 1) % 5
                    node.geometry!.firstMaterial = activeNodeMaterials[newIndex]
                    
                    if newIndex == 0 {
                        nodeColors[nodeIndex!] = nil
                    } else {
                        nodeColors[nodeIndex!] = (node.geometry!.firstMaterial!.diffuse.contents as! UIColor)
                    }
                }
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first!
        let location = touch.location(in: gameView)
        let hitList = gameView.hitTest(location, options: nil)
        
        if let hitObject = hitList.first {
            let node = hitObject.node
            if (node.name?.contains("Cube"))! {
                nextColor(forNode: node)
            }
        }
    }
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

}
