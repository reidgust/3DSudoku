//
//  GameViewController.swift
//  Sudoku3D
//
//  Created by Reid on 2018-11-02.
//  Copyright © 2018 Reid. All rights reserved.
//

import UIKit
import QuartzCore
import CoreData
import SceneKit

class GameViewController: UIViewController {

    var gameView : SCNView!
    var gameScene : SCNScene!
    var cameraNode : SCNNode!
    var level : SudokuLevel?
    var targetCreationTime : TimeInterval = 0
    var nodeColors : [UIColor]?
    var currentLvl : Int = 0
    var xAngle: Float = 0
    var yAngle: Float = 0
    
    override func viewDidLoad() {
        loadCurrentLevel()
        level = SudokuLevel(level: currentLvl)
        nodeColors = level!.getColors()
        super.viewDidLoad()
        initView()
        initScene()
        initCamera()
        createGameObjects()
        addGestures()
    }
    
    private func loadCurrentLevel() {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Game")
        request.returnsObjectsAsFaults = false
        do
        {
            let results = try AppDelegate.context.fetch(request)
            if results.count < 1 {
                currentLvl = 3
            }
            for result in results as! [NSManagedObject] {
                currentLvl = result.value(forKey: "currentLevel") as! Int
            }
        }
        catch
        {
            fatalError("Can't Access CoreData: Game Progress")
        }
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
    
    func createTitleBar() {
        let title = SCNScene(named: "art.scnassets/Title.dae")!
        let titleBar = SCNNode(geometry: SCNBox(width: 20, height: 10, length: 4, chamferRadius: 0.2))
        titleBar.geometry?.firstMaterial?.diffuse.contents = Constants.Colors.clear
        titleBar.name = "TitleBar"
        titleBar.position = SCNVector3(0,35,-70)
        titleBar.light = SCNLight()
        titleBar.light!.type = SCNLight.LightType.ambient
        titleBar.light!.temperature = 500
        titleBar.light!.intensity = 500
        gameScene.rootNode.addChildNode(titleBar)
        for i in 1...12 {
            let lvlNode = SCNNode(geometry : (SCNSphere(radius: 2)))
            switch i {
            case 1...2:
                lvlNode.geometry!.firstMaterial?.diffuse.contents = Constants.Colors.fill1
            case 3...11:
                lvlNode.geometry!.firstMaterial?.diffuse.contents = Constants.Colors.fill2
            case 12:
                lvlNode.geometry!.firstMaterial?.diffuse.contents = Constants.Colors.fill4
            default:
                lvlNode.geometry!.firstMaterial?.diffuse.contents = Constants.Colors.fill4
            }
            lvlNode.name = "lvl\(i)"
            lvlNode.position = SCNVector3(x: Float(i*4 - 24) - 2, y: 10, z: 0)
            titleBar.addChildNode(lvlNode)
        }
        if let geometry = title.rootNode.childNode(withName: "typeMesh1", recursively: true)?.geometry {
            let titleNode = SCNNode(geometry: geometry)
            titleNode.scale = SCNVector3Make(0.8, 0.8, 0.8)
            titleNode.position = SCNVector3(x: -23, y: -5, z: 0)
            titleNode.name = "Title"
            let material = SCNMaterial()
            material.diffuse.contents = Constants.Colors.title
            titleNode.geometry?.firstMaterial = material
            titleBar.addChildNode(titleNode)
        }
    }
    
    func createGameObjects() {
        createTitleBar()

        let sceneObjects = SCNScene(named: "art.scnassets/Set.dae")!
        let frame = sceneObjects.rootNode.childNode(withName: "Frame", recursively: true)
        let cube = sceneObjects.rootNode.childNode(withName: "Cube", recursively: true)

        let masterCube = SCNNode(geometry: SCNBox(width: 0, height: 0, length: 0, chamferRadius: 0))
        let innerCube = SCNNode(geometry: SCNBox(width: 0, height: 0, length: 0, chamferRadius: 0))
        innerCube.geometry?.firstMaterial?.diffuse.contents = Constants.Colors.clear
        masterCube.geometry?.firstMaterial?.diffuse.contents = Constants.Colors.clear
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
            for i in 0..<64 {
                let cubeNode = SCNNode(geometry: cubeGeometry.copy() as? SCNGeometry)
                let frameNode = SCNNode(geometry: frameGeometry.copy() as? SCNGeometry)
                cubeNode.name = "Cube\(i)"
                frameNode.name = "Frame\(i)"
                let cubeScale = SCNVector3Make(2, 2, 2)
                cubeNode.scale = cubeScale
                let frameScale = SCNVector3Make(1, 1, 1)
                frameNode.scale = frameScale
                cubeNode.geometry?.firstMaterial = SCNMaterial()
                cubeNode.geometry?.firstMaterial?.diffuse.contents = nodeColors![i]
                frameNode.geometry?.firstMaterial?.diffuse.contents = Constants.Colors.frame
                
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
                    innerCubeNode.geometry?.firstMaterial = SCNMaterial()
                    innerCubeNode.geometry?.firstMaterial?.diffuse.contents = nodeColors![i]
                    innerFrameNode.geometry?.firstMaterial?.diffuse.contents = Constants.Colors.frame
                    innerCube.addChildNode(innerCubeNode)
                    innerCube.addChildNode(innerFrameNode)
                }
            }
        }
    }
    
    func nextColor(forNode node: SCNNode) {
        if !(node.name?.contains("Cube"))! { return }
        let currentColor = node.geometry?.firstMaterial?.diffuse.contents as! UIColor
        var topIndex : Int = 0
        switch nodeColors!.count {
        case 8:
            topIndex = 2
        case 27:
            topIndex = 3
        case 64:
            topIndex = 4
        case 125:
            topIndex = 5
        default:
            topIndex = 6
        }
        let activeNodeColors = [Constants.Colors.clear,Constants.Colors.fill1Selected,Constants.Colors.fill2Selected,Constants.Colors.fill3Selected,Constants.Colors.fill4Selected,Constants.Colors.fill5Selected]
        if let i = activeNodeColors.firstIndex(of: currentColor)
        {
            let color = activeNodeColors[(i + 1) % (topIndex + 1)]
            node.geometry?.firstMaterial?.diffuse.contents = color
            var nodeIndex : Int?;
            if node.name!.contains("Copy") {
                let start = node.name!.index(node.name!.startIndex, offsetBy: 4)
                let end = node.name!.index(node.name!.endIndex, offsetBy: -4)
                nodeIndex = Int(node.name![start..<end])
            } else {
                nodeIndex = Int(node.name![node.name!.index(node.name!.startIndex, offsetBy: 4)...])
            }
            if (self.level?.setColor(color, atIndex: nodeIndex!))! {
                gameScene.rootNode.childNode(withName: "Frame1", recursively: true)!.geometry?.firstMaterial?.diffuse.contents = Constants.Colors.frameWon
            }
            //self.level?.persistData()
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
                if (node.name?.contains("Copy"))! {
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
        self.gameView.addGestureRecognizer(pinch)
        self.gameView.addGestureRecognizer(pan)
    }

    @objc func pinch(sender:UIPinchGestureRecognizer) {
        if sender.state == .began || sender.state == .changed {
            cameraNode.position = SCNVector3(CGFloat(cameraNode.position.x), CGFloat(cameraNode.position.y), CGFloat(cameraNode.position.z) * sender.scale)
            sender.scale = 1
        }
    }
    
    @objc func pan(sender:UIPanGestureRecognizer) {
        let translation = sender.translation(in: sender.view!)
        var newAngleX : Float = 0
        var newAngleY : Float = 0
        for cube in gameScene.rootNode.childNodes(passingTest:
            { (node, ballYesOrNo) -> Bool in
                if let name = node.name {
                    return name.contains("Inner") || name.contains("Master")
                }
                return false
        }) {
            newAngleX = (Float)(translation.y)*(Float)(Double.pi)/180.0
            newAngleX += xAngle
            newAngleY = (Float)(translation.x)*(Float)(Double.pi)/180.0
            newAngleY += yAngle
            
            cube.eulerAngles.x = newAngleX
            cube.eulerAngles.y = newAngleY
        }
        if (sender.state == .ended) {
            xAngle = newAngleX
            yAngle = newAngleY
        }
    }
    
    override var shouldAutorotate: Bool {
        return false
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }

}
