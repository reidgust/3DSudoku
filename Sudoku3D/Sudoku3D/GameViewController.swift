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
        cameraNode.position = SCNVector3(0, 20, 100)
        gameScene.rootNode.addChildNode(cameraNode)
    }
    
    func createTarget() {
        let scene = SCNScene(named: "art.scnassets/Cubes.dae")
        if let boxNode = scene?.rootNode {
            gameScene.rootNode.addChildNode(boxNode)
        }

        /*for _ in 0 ..< 6{
            let face = SCNMaterial()
            face.diffuse.contents = UIImage(named: FACE_OUTLINE)
            face.isDoubleSided = true
            face.lightingModel = .constant
            faceArray.append(face)
        }
        
        self.geometry?.materials = faceArray */
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
