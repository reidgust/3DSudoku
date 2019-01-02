//
//  TitleNode.swift
//  Sudoku3D
//
//  Created by Reid on 2019-01-01.
//  Copyright © 2019 Reid. All rights reserved.
//

import Foundation
import SceneKit

class TitleNode : SCNNode {
    let currentLevel = SCNText(string: "Current Level", extrusionDepth: 1)
    
    override init() {
        super.init()
        self.geometry = SCNBox(width: 20, height: 10, length: 4, chamferRadius: 0.2)
        self.geometry?.firstMaterial?.diffuse.contents = Constants.Colors.clear
        self.name = "TitleBar"
        self.position = SCNVector3(0,35,-70)
        self.light = SCNLight()
        self.light!.type = SCNLight.LightType.ambient
        self.light!.temperature = 500
        self.light!.intensity = 500
        makeSudokuTitle()
        makeLevelButtons()
        makeCurrentLevelNode()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func makeCurrentLevelNode() {
        currentLevel.font = UIFont (name: "Arial", size: 3)
        currentLevel.firstMaterial!.diffuse.contents = Constants.Colors.frame
        currentLevel.firstMaterial!.specular.contents = Constants.Colors.frame
        let textNode = SCNNode(geometry: currentLevel)
        textNode.name = "currentLevel"
        textNode.position = SCNVector3(x:-5, y: 4, z: 0)
        self.addChildNode(textNode)
    }
    
    private func makeLevelButtons() {
       /* //let lock = CALayer(layer: "art.scnassets/lock-icon.png")
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
        //var image = UIImage(named:"art.scnassets/lock-icon.png")! */
        
        
        for i in 1...12 {
            let lvlNode = SCNNode(geometry : (SCNSphere(radius: 2)))
            switch i {
            case 1...3:
                lvlNode.geometry!.firstMaterial?.diffuse.contents = Constants.Colors.fillColors[8]
            case 4...11:
                lvlNode.geometry!.firstMaterial?.diffuse.contents = Constants.Colors.fillColors[9]
            case 12:
                lvlNode.geometry!.firstMaterial?.diffuse.contents = Constants.Colors.fillColors[10]
            default:
                lvlNode.geometry!.firstMaterial?.diffuse.contents = Constants.Colors.fillColors[10]
            }
            lvlNode.name = "lvl\(i)"
            lvlNode.position = SCNVector3(x: Float(i*4 - 24) - 2, y: 10, z: 0)
            self.addChildNode(lvlNode)
        }
    }
    
    private func makeSudokuTitle() {
        let title = SCNScene(named: "art.scnassets/Title.dae")!
        guard let geometry = title.rootNode.childNode(withName: "typeMesh1", recursively: true)?.geometry else { return }
        let titleNode = SCNNode(geometry: geometry)
        titleNode.scale = SCNVector3Make(0.8, 0.8, 0.8)
        titleNode.position = SCNVector3(x: -23, y: -5, z: 0)
        titleNode.name = "Title"
        let material = SCNMaterial()
        material.diffuse.contents = Constants.Colors.title
        titleNode.geometry?.firstMaterial = material
        self.addChildNode(titleNode)
    }
    
    /*public func clickedHigherLevel() {
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
    }*/
}
