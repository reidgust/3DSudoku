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
    var tutorial = false
    var level : SudokuLevel?
    var switchingToLevel : Int?
    var targetCreationTime : TimeInterval = 0
    var xAngle: Float = 0
    var yAngle: Float = 0
    let sceneObjects = SCNScene(named: "art.scnassets/Set.dae")!
    var store : UpgradeHandler?
    var frame : SCNNode?
    var cube : SCNNode?
    static let activeNodeColors = [Constants.Colors.clear,Constants.Colors.fill1Selected,Constants.Colors.fill2Selected,Constants.Colors.fill3Selected,Constants.Colors.fill4Selected,Constants.Colors.fill5Selected]
    
    override func viewDidLoad() {
        level = SudokuLevel(level: UserDefaults.standard.integer(forKey: "currentLevel"))
        cube = sceneObjects.rootNode.childNode(withName: "Cube", recursively: true)
        frame = sceneObjects.rootNode.childNode(withName: "Frame", recursively: true)
        super.viewDidLoad()
        initView()
        initScene()
        initCamera()
        createGameObjects()
        addGestures()
    }

    public func nothing(){}

    public func setFirstTime() {
        presentTipAlert(withMessage: Constants.Scripts.intro, withTitle: "Welcome!", dismissButton: "Let me play!")
        tutorial = true
    }
    
    public func getCurrentLevel() -> SudokuLevel {
        return level!
    }

    override func viewWillDisappear(_ animated: Bool) {
        level?.persistData()
        UserDefaults.standard.set(level?.getLevelNumber(), forKey: "currentLevel")
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

        //let lock = CALayer(layer: "art.scnassets/lock-icon.png")
        let layer = CALayer()
        layer.frame = CGRect(x:0, y:0, width:1, height:1)
        layer.backgroundColor = Constants.Colors.fill4.cgColor
        
        var textLayer = CATextLayer()
        textLayer.frame = layer.bounds
        textLayer.fontSize = layer.bounds.size.height
        textLayer.string = "Test"
        textLayer.alignmentMode = CATextLayerAlignmentMode.left
        textLayer.foregroundColor = Constants.Colors.title.cgColor
        textLayer.display()
        layer.addSublayer(textLayer)
        //var image = UIImage(named:"art.scnassets/lock-icon.png")!
        
        for i in 1...12 {
            let lvlNode = SCNNode(geometry : (SCNSphere(radius: 2)))
            switch i {
            case 1...3:
                lvlNode.geometry!.firstMaterial?.diffuse.contents = Constants.Colors.fill3
            case 4...11:
                lvlNode.geometry!.firstMaterial?.diffuse.contents = layer
            case 12:
                lvlNode.geometry!.firstMaterial?.diffuse.contents = Constants.Colors.fill5
            default:
                lvlNode.geometry!.firstMaterial?.diffuse.contents = Constants.Colors.fill5
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
            frameNode.geometry?.firstMaterial?.diffuse.contents = level!.isComplete ? Constants.Colors.frameWon : Constants.Colors.frame
            
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
        let names: [String] = ["Master","Inner","Solo"]
        for i in 0..<names.count {
            var changedFrame = false
            for node in gameScene.rootNode.childNode(withName: names[i], recursively: true)?.childNodes ?? [] {
                if (node.name?.contains("Cube"))! {
                    if let nodeIndex = getCubeNumber(node){
                        node.geometry?.firstMaterial?.diffuse.contents = level!.getColour(nodeIndex)
                    }
                }
                if (!changedFrame && (node.name?.contains("Frame"))!) {
                    changedFrame = true
                    if level!.isComplete {
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
    
    func levelPassed() {
        //Update highest level if new level unlocked
        let levelNumber = level!.getLevelNumber()
        if levelNumber == 1 {
            presentTipAlert(withMessage: Constants.Scripts.passedFirstLevel, withTitle: "One down!", dismissButton: "I'm getting it!")
        }
        if levelNumber == 3 {
            presentTipAlert(withMessage: Constants.Scripts.passed3X3, withTitle: "Rock on!", dismissButton: "Awesome Possum!")
        }
        if levelNumber == 6 {
            UserDefaults.standard.set(true, forKey: "beatLevel6")
            if store == nil {store = UpgradeHandler(completion: passedLevel6)}
            else {passedLevel6()}
        }
        if ((levelNumber < 6 || (UserDefaults.standard.value(forKey: "hasPaid")) as! Bool) && levelNumber < 12 ){
            UserDefaults.standard.set(level!.getLevelNumber() + 1, forKey: "highestLevel")
            //TODO: Update level buttons
        }
    }
    
    func passedLevel6(){
        if !((UserDefaults.standard.value(forKey: "hasPaid")) as! Bool) {
            presentTipAlert(withMessage: Constants.Scripts.doneFreeLevels, withTitle: "Upgrade", dismissButton: "Thanks!")
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
            // Check to see if that change wins the level
            switch (self.level?.setColor(color, atIndex: nodeIndex!))! {
            case LevelStatus.wonFirstTime:
                levelPassed()
                fallthrough
            case LevelStatus.wonAgain:
                gameScene.rootNode.childNode(withName: "Frame1", recursively: true)!.geometry?.firstMaterial?.diffuse.contents = Constants.Colors.frameWon
            case LevelStatus.undidWin:
                gameScene.rootNode.childNode(withName: "Frame1", recursively: true)!.geometry?.firstMaterial?.diffuse.contents = Constants.Colors.frame
            case LevelStatus.normal:
                break
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
    
    func presentTipAlert(withMessage message : String, withTitle title : String = "", dismissButton : String = "That's cool.") {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: dismissButton, style: .cancel, handler: nil))
        self.present(alert, animated: true)
    }
    
    func presentActionSheet(withMessage message: String, currentLevel : Bool = false, random : Bool = false) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .actionSheet)
        alert.popoverPresentationController?.sourceView = self.view!
        alert.addAction(UIAlertAction(title: "Continue Current Level", style: .cancel, handler: nil))
        if currentLevel {
            alert.addAction(UIAlertAction(title: "Reset Level", style: .default, handler: { action in
                for i in 0..<self.level!.getSize() {
                    switch self.level?.getColour(i){
                    case Constants.Colors.fill1Selected, Constants.Colors.fill2Selected, Constants.Colors.fill3Selected, Constants.Colors.fill4Selected, Constants.Colors.fill5Selected:
                        self.level?.setColor(i, colour: Constants.Colors.clear)
                        self.level?.isComplete = false
                        self.changeAllCubeColors()
                    default:
                        continue
                    }
                }
            }))
            if random {
                alert.addAction(UIAlertAction(title: "New Random Level", style: .default, handler: { action in
                    self.level = SudokuLevel(level: (self.level?.getLevelNumber())!, random : true)
                    self.changeAllCubeColors()
                }))
            }
        }
        if !UserDefaults.standard.bool(forKey: "hasPaid") {
            alert.addAction(UIAlertAction(title:"Upgrade For Unlimited Levels", style: .default, handler: { action in
                if self.store == nil { self.store = UpgradeHandler(completion: self.responseToPurchaseRequest)}
                else { self.responseToPurchaseRequest() }
            }))
        }
        
        self.present(alert, animated: true)
    }
    
    func responseToPurchaseRequest() {
        let (success,message) = self.store!.getPaymentAlertInfo()
        if success {
            let alert = UIAlertController(title: "Upgrade", message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "No thanks.", style: .cancel, handler: nil))
            alert.addAction(UIAlertAction(title: "Upgrade!", style: .default, handler: { click in
                self.store!.buyProduct()
            }))
            self.present(alert, animated: true)
        } else {
            presentTipAlert(withMessage: message, withTitle: "Unable To Upgrade", dismissButton: "OH NO!")
        }
    }
    
    func switchTo(level: Int) {
        switchingToLevel = level
        if level == self.level?.levelNumber {
            presentActionSheet(withMessage: "You're currently playing level \(level)", currentLevel: true, random: ((level == 3 || level == 11 || level == 12) && self.level!.hasPassed))
            return
        }
        if level > 6 {
            if store == nil {store = UpgradeHandler(completion: clickedHigherLevel)}
            else {clickedHigherLevel()}
        }
        else if level <= UserDefaults.standard.integer(forKey: "highestLevel") {
            let currentSize = self.level?.getSize()
            self.level?.persistData()
            self.level = SudokuLevel(level: level)
            updateNumberOfCubeObjects(currentSize: currentSize!, newSize: (self.level?.getSize())!)
            changeAllCubeColors()
            if level == 2 && tutorial {
                presentTipAlert(withMessage: Constants.Scripts.secondLevel, withTitle: "Center Cube", dismissButton: "Makes Sense!")
                tutorial = false
            }
        } else {
            presentActionSheet(withMessage: "Level \(level) is currently blocked and will be unblocked when you beat level \(level - 1)")
        }
    }
    
    func clickedHigherLevel() {
        if !UserDefaults.standard.bool(forKey: "hasPaid") {
            presentActionSheet(withMessage: "Level \(switchingToLevel!) is currently blocked. Only levels 1-6 are available in free play. Upgrade for unlimited 4X4 and 5X5 levels.")
        } else if switchingToLevel! <= UserDefaults.standard.integer(forKey: "highestLevel") {
            let currentSize = self.level?.getSize()
            self.level?.persistData()
            self.level = SudokuLevel(level: switchingToLevel!)
            updateNumberOfCubeObjects(currentSize: currentSize!, newSize: (self.level?.getSize())!)
            changeAllCubeColors()
        } else {
            presentActionSheet(withMessage: "Level \(switchingToLevel!) is currently blocked and will be unblocked when you beat level \(switchingToLevel! - 1)")
        }
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
