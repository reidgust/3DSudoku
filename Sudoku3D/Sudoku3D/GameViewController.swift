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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initView()
        initScene()
        initCamera()
        createTarget()
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
    
    func createTarget() {
        let sceneObjects = SCNScene(named: "art.scnassets/Set.dae")!
        let title = SCNScene(named: "art.scnassets/Title.dae")!
        let frame = sceneObjects.rootNode.childNode(withName: "Frame", recursively: true)
        let cube = sceneObjects.rootNode.childNode(withName: "Cube", recursively: true)
        
        if let geometry = title.rootNode.childNode(withName: "typeMesh1", recursively: true)?.geometry {
            let titleNode = SCNNode(geometry: geometry)
            titleNode.scale = SCNVector3Make(0.5, 0.5, 0.5)
            titleNode.position = SCNVector3(x: -14 , y: 10, z: -20)
            let newMaterial2 = SCNMaterial()
            newMaterial2.diffuse.contents = Constants.Colors.title
            titleNode.geometry?.firstMaterial = newMaterial2
            gameScene.rootNode.addChildNode(titleNode)
        }
        
        if let boxGeometry = cube?.geometry {
            for i in 0..<64 {
                let box2Geometry = boxGeometry.copy() as! SCNGeometry
                let box2GeometryNode = SCNNode(geometry: box2Geometry)
                box2GeometryNode.scale = SCNVector3Make(2, 2, 2)
                box2GeometryNode.name = "Cube\(i)"
                box2GeometryNode.position = SCNVector3(x: Float(i%4)*2, y: Float((i/4)%4)*2 - 10, z: Float((i/16)%4)*2)
                let newMaterial2 = SCNMaterial()
                switch arc4random() % 11 {
                case 0:
                    newMaterial2.diffuse.contents = Constants.Colors.fill4
                case 1:
                    newMaterial2.diffuse.contents = Constants.Colors.fill1
                case 2:
                    newMaterial2.diffuse.contents = Constants.Colors.fill2
                case 3:
                    newMaterial2.diffuse.contents = Constants.Colors.fill3
                default:
                    newMaterial2.diffuse.contents = Constants.Colors.clear
                }

                box2GeometryNode.geometry?.firstMaterial = newMaterial2
                if (i%4 == 1 || i%4 == 2) && ((i/4)%4 == 1 || (i/4)%4 == 2) && ((i/16)%4 == 1 || (i/16)%4 == 2)  {
                    let innerCubePiece = box2GeometryNode.copy() as! SCNNode
                    innerCubePiece.position = SCNVector3(x: Float(i%4)*2 + 8, y: Float((i/4)%4)*2 - 2, z: Float((i/16)%4)*2 - 8)
                    gameScene.rootNode.addChildNode(innerCubePiece)
                }
                gameScene.rootNode.addChildNode(box2GeometryNode)
            }
        }
        
        if let boxGeometry = frame?.geometry {
            let newMaterial2 = SCNMaterial()
            newMaterial2.diffuse.contents = Constants.Colors.frame
            for i in 0..<64 {
                let box2GeometryNode = SCNNode(geometry: boxGeometry)
                box2GeometryNode.scale = SCNVector3Make(1, 1, 1)
                box2GeometryNode.position = SCNVector3(x: Float(i%4)*2, y: Float((i/4)%4)*2 - 10, z: Float((i/16)%4)*2)
                box2GeometryNode.geometry?.firstMaterial = newMaterial2
                if (i%4 == 1 || i%4 == 2) && ((i/4)%4 == 1 || (i/4)%4 == 2) && ((i/16)%4 == 1 || (i/16)%4 == 2)  {
                    let innerCubePiece = box2GeometryNode.copy() as! SCNNode
                    innerCubePiece.position = SCNVector3(x: Float(i%4)*2 + 8, y: Float((i/4)%4)*2 - 2, z: Float((i/16)%4)*2 - 8)
                    gameScene.rootNode.addChildNode(innerCubePiece)
                }
                gameScene.rootNode.addChildNode(box2GeometryNode)
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
