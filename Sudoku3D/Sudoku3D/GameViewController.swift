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
    var xAngle: Float = 0
    var yAngle: Float = 0
    let sceneObjects = SCNScene(named: "art.scnassets/Set.dae")!
    var frame : SCNNode?
    var cube : SCNNode?
    static let activeNodeColors = [Constants.Colors.clear,Constants.Colors.fill1Selected,Constants.Colors.fill2Selected,Constants.Colors.fill3Selected,Constants.Colors.fill4Selected,Constants.Colors.fill5Selected]
    
    override func viewDidLoad() {
        loadCurrentLevel()
        cube = sceneObjects.rootNode.childNode(withName: "Cube", recursively: true)
        frame = sceneObjects.rootNode.childNode(withName: "Frame", recursively: true)
        super.viewDidLoad()
        initView()
        initScene()
        initCamera()
        createGameObjects()
        addGestures()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        level?.persistData()
        persistData()
    }
    
    private func persistData(hasPaid : Bool? = nil) {
        if let result = loadCurrentLevel() {
            result.setValue(level?.getLevelNumber(), forKey: "currentLevel")
        }
        else
        {
            let newGame = NSEntityDescription.insertNewObject(forEntityName: "Game", into: AppDelegate.context)
            if let hasPaid = hasPaid {
                newGame.setValue(hasPaid, forKey: "hasPaid")
            }
            newGame.setValue(level!.getLevelNumber(), forKey: "currentLevel")
            do
            {
                try AppDelegate.context.save()
                print("SAVED")
            }
            catch
            {
                //TODO: Error handling.
            }
        }
    }
    
    private func loadCurrentLevel() -> NSManagedObject? {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Game")
        request.returnsObjectsAsFaults = false
        do
        {
            let result = try AppDelegate.context.fetch(request)
            if result.count < 1 {
                level = SudokuLevel(level: 3)
                return nil
            }
            level = SudokuLevel(level: (result[0] as! NSManagedObject).value(forKey: "currentLevel") as! Int)
            return result[0] as? NSManagedObject
        }
        catch
        {
            fatalError("Can't Access CoreData: Game Progress")
        }
        return nil
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
    
    func getCubePosition(index i: Int) -> SCNVector3{
        let dim = level!.getDimension()
        let scale : Float = dim == 5 ? 1.5 : 2
        let offset = (Float(dim) / 2) - 0.5
        let position = SCNVector3(
            x: (Float(i % dim) - offset) * scale,
            y: ((Float((i / dim) % dim)) - offset) * scale,
            z: ((Float(((i / (dim*dim)) % dim)) - offset) * scale))
        return position
    }
    
    func getMasterCube(make:Bool) -> SCNNode? {
        if let master = self.gameScene.rootNode.childNode(withName: "Master", recursively: true) {return master}
        if !make {return nil}
        let masterCube = SCNNode(geometry: SCNBox(width: 0, height: 0, length: 0, chamferRadius: 0))
        masterCube.geometry?.firstMaterial?.diffuse.contents = Constants.Colors.clear
        masterCube.name = "Master"
        gameScene.rootNode.addChildNode(masterCube)
        return masterCube
    }
    
    func getInnerCube(make:Bool) -> SCNNode? {
        if let inner = self.gameScene.rootNode.childNode(withName: "Inner", recursively: true) {return inner}
        if !make {return nil}
        let innerCube = SCNNode(geometry: SCNBox(width: 0, height: 0, length: 0, chamferRadius: 0))
        innerCube.geometry?.firstMaterial?.diffuse.contents = Constants.Colors.clear
        innerCube.name = "Inner"
        innerCube.light = SCNLight()
        innerCube.light!.type = SCNLight.LightType.ambient
        innerCube.light!.temperature = 500
        innerCube.light!.intensity = 500
        gameScene.rootNode.addChildNode(innerCube)
        return innerCube
    }
    
    func getTinyCube(make:Bool) -> SCNNode? {
        if let tinyCube = self.gameScene.rootNode.childNode(withName: "Solo", recursively: true) {return tinyCube}
        if !make {return nil}
        let tinyCube = SCNNode(geometry: SCNBox(width: 0, height: 0, length: 0, chamferRadius: 0))
        tinyCube.geometry?.firstMaterial?.diffuse.contents = Constants.Colors.clear
        tinyCube.name = "Solo"
        tinyCube.position = SCNVector3(0,-14,0)
        tinyCube.light = SCNLight()
        tinyCube.light!.type = SCNLight.LightType.ambient
        tinyCube.light!.temperature = 500
        tinyCube.light!.intensity = 500
        tinyCube.eulerAngles.x = xAngle
        tinyCube.eulerAngles.y = yAngle
        gameScene.rootNode.addChildNode(tinyCube)
        return tinyCube
    }
    
    func createAndPlaceCube(index i: Int){
        let masterCube = getMasterCube(make:true)
        if let cubeGeometry = cube?.geometry, let frameGeometry = frame?.geometry {
            let cubeNode = SCNNode(geometry: cubeGeometry.copy() as? SCNGeometry)
            let frameNode = SCNNode(geometry: frameGeometry.copy() as? SCNGeometry)
            cubeNode.name = "Cube\(i)"
            frameNode.name = "Frame\(i)"
            let dim = level!.getDimension()
            masterCube!.position = SCNVector3(0,dim == 5 ? 2 : 0,0)
            let scale : Float = dim == 5 ? 1.5 : 2
            let cubeScale = SCNVector3Make(scale, scale, scale)
            cubeNode.scale = cubeScale
            let frameScale = SCNVector3Make(scale/2, scale/2, scale/2)
            frameNode.scale = frameScale
            cubeNode.geometry?.firstMaterial = SCNMaterial()
            cubeNode.geometry?.firstMaterial?.diffuse.contents = level!.getColour(i)
            frameNode.geometry?.firstMaterial?.diffuse.contents = level!.getHasPassed() ? Constants.Colors.frameWon : Constants.Colors.frame
            
            cubeNode.position = getCubePosition(index:i)
            frameNode.position = cubeNode.position
            
            masterCube!.addChildNode(cubeNode)
            masterCube!.addChildNode(frameNode)

            if (i%dim != 0 && i%dim != dim-1) && ((i/dim)%dim != 0 && (i/dim)%dim != dim-1) && ((i/(dim*dim))%dim != 0 && (i/(dim*dim))%dim != dim-1)  {
                let innerCube = getInnerCube(make:true)
                innerCube!.position = SCNVector3(0,dim == 5 ? -8 : -10,0)
                let innerCubeNode = SCNNode(geometry: cubeGeometry.copy() as? SCNGeometry)
                let innerFrameNode = SCNNode(geometry: frameGeometry.copy() as? SCNGeometry)
                innerCubeNode.name = "Cube\(i)Copy"
                innerFrameNode.name = "Frame\(i)Copy"
                innerCubeNode.scale = cubeScale
                innerFrameNode.scale = frameScale
                innerCubeNode.position = cubeNode.position
                innerFrameNode.position = cubeNode.position
                innerCubeNode.geometry?.firstMaterial = SCNMaterial()
                innerCubeNode.geometry?.firstMaterial?.diffuse.contents = level!.getColour(i)
                innerFrameNode.geometry?.firstMaterial?.diffuse.contents = Constants.Colors.frame
                innerCube!.addChildNode(innerCubeNode)
                innerCube!.addChildNode(innerFrameNode)
                
                if dim == 5 && i == 62 {
                    let tinyCube = getTinyCube(make:true)
                    let tinyCubeNode = innerCubeNode.copy() as! SCNNode//SCNNode(geometry: cubeGeometry.copy() as? SCNGeometry)
                    let tinyFrameNode = innerFrameNode.copy() as! SCNNode//SCNNode(geometry: frameGeometry.copy() as? SCNGeometry)
                    tinyCubeNode.name = "Cube\(i)Tiny"
                    tinyFrameNode.name = "Frame\(i)Tiny"
                    tinyCubeNode.scale = cubeScale
                    tinyFrameNode.scale = frameScale
                    tinyCubeNode.position = cubeNode.position
                    tinyFrameNode.position = cubeNode.position
                    tinyCubeNode.geometry?.firstMaterial = SCNMaterial()
                    tinyCubeNode.geometry?.firstMaterial?.diffuse.contents = level!.getColour(i)
                    tinyFrameNode.geometry?.firstMaterial?.diffuse.contents = Constants.Colors.frame
                    tinyCube!.addChildNode(tinyCubeNode)
                    tinyCube!.addChildNode(tinyFrameNode)
                }
            }
        }
    }

    func removeCubes(oldSize: Int) {
        if oldSize == 125 {
            if let tiny = getTinyCube(make:false) {
                for node in tiny.childNodes {
                    node.removeFromParentNode()
                }
                tiny.removeFromParentNode()
            }
        }
        for i in 0...1 {
            let cube = i==0 ? getMasterCube(make: false)! : getInnerCube(make:false)!
            for node in cube.childNodes {
                if getCubeNumber(node) != nil {
                    node.removeFromParentNode()
                }
            }
        }
    }
    
    func createGameObjects() {
        createTitleBar()

        for i in 0..<level!.getSize() {
            createAndPlaceCube(index: i)
        }
    }
    
    func changeAllCubeColors() {
        let names: [String] = ["Master","Inner"]
        for i in 0..<names.count {
            var changedFrame = false
            for node in gameScene.rootNode.childNode(withName: names[i], recursively: true)!.childNodes{
                if (node.name?.contains("Cube"))! {
                    if let nodeIndex = getCubeNumber(node){
                        node.geometry?.firstMaterial?.diffuse.contents = level!.getColour(nodeIndex)
                    }
                }
                if (!changedFrame && (node.name?.contains("Frame"))!) {
                    changedFrame = true
                    if level!.getHasPassed() {
                        node.geometry?.firstMaterial?.diffuse.contents = Constants.Colors.frameWon
                    } else {
                        node.geometry?.firstMaterial?.diffuse.contents = Constants.Colors.frame
                    }
                }
            }
        }
    }
    
    func getCubeNumber(_ node: SCNNode) -> Int? {
        if (node.name!.contains("Copy") || node.name!.contains("Tiny")) {
            let start = node.name!.index(node.name!.startIndex, offsetBy: node.name!.contains("Cube") ? 4 : 5)
            let end = node.name!.index(node.name!.endIndex, offsetBy: -4)
            return Int(node.name![start..<end])
        } else {
            return Int(node.name![node.name!.index(node.name!.startIndex, offsetBy: node.name!.contains("Cube") ? 4 : 5)...])
        }
    }
    
    func nextColor(forNode node: SCNNode) {
        if !(node.name?.contains("Cube"))! { return }
        let currentColor = node.geometry?.firstMaterial?.diffuse.contents as! UIColor
        let topIndex : Int = level!.getDimension()
        if let i = GameViewController.activeNodeColors.firstIndex(of: currentColor)
        {
            let color = GameViewController.activeNodeColors[(i + 1) % (topIndex + 1)]
            node.geometry?.firstMaterial?.diffuse.contents = color
            let nodeIndex = getCubeNumber(node)
            if (self.level?.setColor(color, atIndex: nodeIndex!))! {
                gameScene.rootNode.childNode(withName: "Frame1", recursively: true)!.geometry?.firstMaterial?.diffuse.contents = Constants.Colors.frameWon
            }
        }
    }
    
    func updateNumberOfCubeObjects(currentSize:Int, newSize:Int) {
        if currentSize == newSize {return}
        removeCubes(oldSize: currentSize)
        for i in 0..<newSize {
            createAndPlaceCube(index:i)
        }
    }
    
    func switchTo(level: Int) {
        if level == self.level?.levelNumber {
            // TODO: UIAlertView: Reset Level. Random Level. Continue. Pay
            return
        }
        let currentSize = self.level?.getSize()
        //self.level?.persistData()
        self.level = SudokuLevel(level: level)
        updateNumberOfCubeObjects(currentSize: currentSize!, newSize: (self.level?.getSize())!)
        changeAllCubeColors()
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first!
        let location = touch.location(in: gameView)
        let hitList = gameView.hitTest(location, options: nil)
        
        for hitObject in hitList {
            let node = hitObject.node
            if (node.name?.contains("Cube"))! {
                if ((node.name?.contains("Copy"))! || (node.name?.contains("Tiny"))!) {
                    let name = String(node.name![..<node.name!.index(node.name!.endIndex, offsetBy: -4)])
                    nextColor(forNode: self.gameScene.rootNode.childNode(withName: name, recursively: true)!)
                }
                nextColor(forNode: node)
            }
            if (node.name?.contains("lvl"))! {
                let lvl = Int(node.name![node.name!.index(node.name!.startIndex, offsetBy: 3)...])
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
                    return name.contains("Inner") || name.contains("Master") || name.contains("Solo")
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
