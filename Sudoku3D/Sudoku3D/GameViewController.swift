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

class GameViewController: UIViewController, LevelObserver {
    var gameView : SCNView!
    var gameScene : SCNScene!
    var cameraNode : SCNNode!
    var alertManager : AlertManager?
    var level : SudokuLevel?
    var store : UpgradeHandler?
    var switchingToLevel : Int?
    var targetCreationTime : TimeInterval = 0
    var cubeStructures : [CubeStructure] = []
    var xAngle: Float = 0
    var yAngle: Float = 0
    var id: Int = 1
    
    override func viewDidLoad() {
        alertManager = AlertManager(caller: self)
        level = SudokuLevel(level: UserDefaults.standard.integer(forKey: "currentLevel"))
        super.viewDidLoad()
        initView()
        initScene()
        initCamera()
        createGameObjects()
        addGestures()
    }

    public func setFirstTime() {
        alertManager!.presentTipAlert(withMessage: Constants.Scripts.intro, withTitle: "Welcome!", dismissButton: "Let me play!")
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
    
    func createGameObjects() {
        gameScene.rootNode.addChildNode(TitleNode())
        makeCubes()
    }
    
    func makeCubes() {
        let dim = (level?.getDimension())!
        cubeStructures.append(CubeStructure(numberOfColors: dim, dimension: dim , delegate: self))
        gameScene.rootNode.addChildNode(cubeStructures[0])
        cubeStructures.append(CubeStructure(numberOfColors: dim, dimension: dim - 2, delegate: self, masterCube: cubeStructures[0]))
        gameScene.rootNode.addChildNode(cubeStructures[1])
        if dim == 5 {
            cubeStructures.append(CubeStructure(numberOfColors: dim, dimension: 1, delegate: self, masterCube: cubeStructures[0]))
            gameScene.rootNode.addChildNode(cubeStructures[2])
        }
        level?.addObserver(cubeStructures[0])
    }
    
    func resetCube() { level?.resetLevel() }

    func randomLevel() {
        let currentSize = level?.getSize()
        level = SudokuLevel(level: (level?.getLevelNumber())!, random: true)
        updateNumberOfCubeObjects(previousSize : currentSize!)
    }
    
    func purchaseRequest() {
        let (success,message) = self.store!.getPaymentAlertInfo()
        alertManager!.responseToPurchaseRequest(success:success,message:message)
    }
    
    func buyProduct() {
        self.store!.buyProduct()
    }

    func update(block: Int, colorIndex: UInt8, status: LevelStatus) {
        if status == .wonFirstTime {
            levelPassed()
        }
    }
    func update(state: [UInt8], complete: Bool) { }// Nothing
    
    func levelPassed() {
        let levelNumber = level!.getLevelNumber()
        if levelNumber == 1 {
            alertManager!.presentTipAlert(withMessage: Constants.Scripts.passedFirstLevel, withTitle: "One down!", dismissButton: "I'm getting it!")
        } else if levelNumber == 3 {
            alertManager!.presentTipAlert(withMessage: Constants.Scripts.passed3X3, withTitle: "Rock on!", dismissButton: "Awesome Possum!")
        } else if levelNumber == 6 {
            UserDefaults.standard.set(true, forKey: "beatLevel6")
            if (!UserDefaults.standard.bool(forKey: "hasPaid") && store == nil) {store = UpgradeHandler(completion: passedLevel6)}
            else {passedLevel6()}
        }
        if ((levelNumber < 6 || (UserDefaults.standard.value(forKey: "hasPaid")) as! Bool) && levelNumber < 12 ){
            UserDefaults.standard.set(level!.getLevelNumber() + 1, forKey: "highestLevel")
            //TODO: Update level buttons
        }
    }
    
    func passedLevel6(){
        if !((UserDefaults.standard.value(forKey: "hasPaid")) as! Bool) {
            alertManager!.presentTipAlert(withMessage: Constants.Scripts.doneFreeLevels, withTitle: "Upgrade", dismissButton: "Thanks!")
        }
    }
    
    func updateNumberOfCubeObjects(previousSize : Int) {
        level?.addObserver(self)
        if !(previousSize == self.level?.getSize()) {
            cubeStructures = []
            makeCubes()
        }
        level?.addObserver(cubeStructures[0])
    }
    
    func switchTo(level: Int) {
        switchingToLevel = level
        if level == self.level?.levelNumber {
            alertManager!.presentActionSheet(withMessage: "You're currently playing level \(level)", currentLevel: true, random: ((level == 3 || level == 11 || level == 12) && self.level!.hasPassed))
            return
        }
        if level > 6 {
            if (!UserDefaults.standard.bool(forKey: "hasPaid") && store == nil) {store = UpgradeHandler(completion: clickedHigherLevel)}
            else {clickedHigherLevel()}
        }
        else if level <= UserDefaults.standard.integer(forKey: "highestLevel") {
            let currentSize = self.level?.getSize()
            self.level?.persistData()
            self.level = SudokuLevel(level: level)
            updateNumberOfCubeObjects(previousSize : currentSize!)
            if level == 2 && UserDefaults.standard.bool(forKey: "showLevel2Tip")  {
                alertManager!.presentTipAlert(withMessage: Constants.Scripts.secondLevel, withTitle: "Center Cube", dismissButton: "Makes Sense!")
                UserDefaults.standard.set(false, forKey: "showLevel2Tip")
            }
        } else {
            alertManager!.presentActionSheet(withMessage: "Level \(level) is currently blocked and will be unblocked when you beat level \(level - 1)")
        }
    }
    
    func clickedHigherLevel() {
        if !UserDefaults.standard.bool(forKey: "hasPaid") {
            alertManager!.presentActionSheet(withMessage: "Level \(switchingToLevel!) is currently blocked. Only levels 1-6 are available in free play. Upgrade for unlimited 4X4 and 5X5 levels.")
        } else if switchingToLevel! <= UserDefaults.standard.integer(forKey: "highestLevel") {
            let currentSize = self.level?.getSize()
            self.level?.persistData()
            self.level = SudokuLevel(level: switchingToLevel!)
            updateNumberOfCubeObjects(previousSize : currentSize!)
        } else {
            alertManager!.presentActionSheet(withMessage: "Level \(switchingToLevel!) is currently blocked and will be unblocked when you beat level \(switchingToLevel! - 1)")
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first!
        let location = touch.location(in: gameView)
        let hitList = gameView.hitTest(location, options: nil)
        
        for hitObject in hitList {
            let node = hitObject.node
            if (node.name?.contains("Cube"))! {
                level!.nextColor(atIndex: (node as! Cube).getCubeNumber())
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
        var newAngleX : Float = (Float)(translation.y)*(Float)(Double.pi)/180.0
        var newAngleY : Float = (Float)(translation.x)*(Float)(Double.pi)/180.0
        newAngleX += xAngle
        newAngleY += yAngle
        
        for cs in cubeStructures {
            cs.updateAngles(x: newAngleX, y: newAngleY)
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
