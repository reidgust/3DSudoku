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
    var currentLvl : Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initView()
        initScene()
        initCamera()
        createGameObjects()
        addGestures()
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
        gameView.allowsCameraControl = false
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
        cameraNode.position = SCNVector3(0, 0, 30)
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
            titleNode.scale = SCNVector3Make(0.8, 0.8, 0.8)
            titleNode.position = SCNVector3(x: -23, y: 25, z: -70)
            titleNode.name = "Title"
            let newMaterial2 = SCNMaterial()
            newMaterial2.diffuse.contents = Constants.Colors.title
            titleNode.geometry?.firstMaterial = newMaterial2
            gameScene.rootNode.addChildNode(titleNode)
        }

        let masterCube = SCNNode(geometry: SCNBox(width: 0, height: 0, length: 0, chamferRadius: 0))
        let innerCube = SCNNode(geometry: SCNBox(width: 0, height: 0, length: 0, chamferRadius: 0))
        innerCube.geometry?.firstMaterial = activeNodeMaterials[0]
        masterCube.geometry?.firstMaterial = activeNodeMaterials[0]
        masterCube.name = "Master"
        innerCube.name = "Inner"
        innerCube.position = SCNVector3(0,-10,0)
        innerCube.light = SCNLight()
        innerCube.light!.type = SCNLight.LightType.ambient
        innerCube.light!.temperature = 500
        innerCube.light!.intensity = 500
        gameScene.rootNode.addChildNode(masterCube)
        gameScene.rootNode.addChildNode(innerCube)

        if let cubeGeometry = cube?.geometry, let frameGeometry = frame?.geometry {
            let newMaterial = SCNMaterial()
            newMaterial.diffuse.contents = Constants.Colors.frame
            for i in 0..<64 {
                let cubeNode = SCNNode(geometry: cubeGeometry.copy() as? SCNGeometry)
                let frameNode = SCNNode(geometry: frameGeometry.copy() as? SCNGeometry)
                cubeNode.name = "Cube\(i)"
                frameNode.name = "Frame\(i)"
                let cubeScale = SCNVector3Make(2, 2, 2)
                cubeNode.scale = cubeScale
                let frameScale = SCNVector3Make(1, 1, 1)
                frameNode.scale = frameScale
                let showColor = arc4random_uniform(64) < 20
                cubeNode.geometry?.firstMaterial = showColor ?  materials[nodeColors[i]!] : activeNodeMaterials[0]
                frameNode.geometry?.firstMaterial = newMaterial
                
                let position = SCNVector3(
                    x: (Float(i % 4) - 1.5) * 2,
                    y: ((Float((i / 4) % 4)) - 1.5) * 2,
                    z: ((Float((i / 16) % 4)) - 1.5) * 2)
                cubeNode.position = position
                frameNode.position = position
                
                masterCube.addChildNode(cubeNode)
                masterCube.addChildNode(frameNode)
                
                if (i%4 == 1 || i%4 == 2) && ((i/4)%4 == 1 || (i/4)%4 == 2) && ((i/16)%4 == 1 || (i/16)%4 == 2)  {
                    let innerCubeNode = SCNNode(geometry: cubeGeometry.copy() as? SCNGeometry)
                    let innerFrameNode = SCNNode(geometry: frameGeometry.copy() as? SCNGeometry)
                    innerCubeNode.name = "Cube\(i)Copy"
                    innerFrameNode.name = "Frame\(i)Copy"
                    innerCubeNode.scale = cubeScale
                    innerFrameNode.scale = frameScale
                    innerCubeNode.position = position
                    innerFrameNode.position = position
                    innerCubeNode.geometry?.firstMaterial = showColor ?  materials[nodeColors[i]!] : activeNodeMaterials[0]
                    innerFrameNode.geometry?.firstMaterial = newMaterial
                    innerCube.addChildNode(innerCubeNode)
                    innerCube.addChildNode(innerFrameNode)
                }
            }
        }
    }
    
    func nextColor(forNode node: SCNNode) {
        if !(node.name?.contains("Cube"))! { return }
        var nodeIndex : Int?;
        if node.name!.contains("Copy") {
            let start = node.name!.index(node.name!.startIndex, offsetBy: 4)
            let end = node.name!.index(node.name!.endIndex, offsetBy: -4)
            nodeIndex = Int(node.name![start..<end])
        } else {
            nodeIndex = Int(node.name![node.name!.index(node.name!.startIndex, offsetBy: 4)...])
        }
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
    
    func switchTo(level: Int) {
        if level == currentLvl { return }
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first!
        let location = touch.location(in: gameView)
        let hitList = gameView.hitTest(location, options: nil)
        
        for hitObject in hitList {
            let node = hitObject.node
            if (node.name?.contains("Cube"))! {
                if node.name == "Copy" {
                    let name = String(node.name![..<node.name!.index(node.name!.endIndex, offsetBy: -4)])
                    nextColor(forNode: self.gameScene.rootNode.childNode(withName: name, recursively: true)!)
                }
                nextColor(forNode: node)
            }
            if (node.name?.contains("Lvl"))! {
                let lvl = Int(node.name![node.name!.index(node.name!.endIndex, offsetBy: 3)...])
                self.switchTo(level: lvl!)
            }
        }
    }

    func addGestures() {
        let pinch = UIPinchGestureRecognizer(target: self, action: #selector(pinch(sender:)))
        let pan = UIPanGestureRecognizer(target: self, action: #selector(pan(sender:)))
        let rotate = UIRotationGestureRecognizer(target:self, action: #selector(rotate(sender:)))
        self.gameView.addGestureRecognizer(pinch)
        self.gameView.addGestureRecognizer(pan)
        self.gameView.addGestureRecognizer(rotate)
    }

    @objc func pinch(sender:UIPinchGestureRecognizer) {
        if sender.state == .began || sender.state == .changed {
            cameraNode.position = SCNVector3(CGFloat(cameraNode.position.x), CGFloat(cameraNode.position.y), CGFloat(cameraNode.position.z) * sender.scale)
            sender.scale = 1
        }
    }
    
    @objc func pan(sender:UIPanGestureRecognizer) {
        //if sender.state == .began || sender.state == .changed {
        let translation = sender.translation(in: sender.view!)
        for cube in gameScene.rootNode.childNodes(passingTest:
            { (node, ballYesOrNo) -> Bool in
                if let name = node.name {
                    return name.contains("Master")
                }
                return false
        }) {
            let x = Float(translation.x)
            let y = Float(-translation.y)
            let anglePan = (sqrt(pow(x,2)+pow(y,2)))*(Float)(Double.pi)/180.0
            cube.rotation = SCNVector4(-y,x,0,anglePan)
        }
        for cube in gameScene.rootNode.childNodes(passingTest:
            { (node, ballYesOrNo) -> Bool in
                if let name = node.name {
                    return name.contains("Inner")
                }
                return false
        }) {
            let x = Float(translation.x)
            let y = Float(-translation.y)
            let anglePan = (sqrt(pow(x,2)+pow(y,2)))*(Float)(Double.pi)/180.0
            cube.rotation = SCNVector4(-y,x, 0 ,anglePan)
        }
    }
    
    @objc func rotate(sender:UIRotationGestureRecognizer) {
        
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
