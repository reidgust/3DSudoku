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
    let levelButtonSize = Float(GameViewController.screenWidth) / 200
    
    override init() {
        super.init()
        self.name = "TitleBar"
        self.position = SCNVector3(0, 5 * Float(GameViewController.screenWidth) / 53,0) // Max Height Cube reaches
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
        currentLevel.firstMaterial!.diffuse.contents = Constants.Colors.title
        currentLevel.firstMaterial!.specular.contents = Constants.Colors.title
        let textNode = SCNNode(geometry: currentLevel)
        textNode.name = "currentLevel"
        textNode.position = SCNVector3(x: -10, y: -5, z: 0)
        self.addChildNode(textNode)
    }
    
    private func makeLevelButtons() {
        let highestLevel = UserDefaults.standard.integer(forKey: "highestLevel")
        for i in 1...12 {
            let lvlNode = SCNNode(geometry : (SCNSphere(radius: CGFloat(levelButtonSize))))
            let image = imageWithText(text:highestLevel >= i ? "\(i)" : "X", backgroundColor: getLevelIconColor(i))
            lvlNode.geometry!.firstMaterial?.diffuse.contents = image
            lvlNode.name = "lvl\(i)"
            let xPos : Float = (2*Float(i)-13) * levelButtonSize
            lvlNode.position = SCNVector3(x: xPos, y: 12, z: 0)
            self.addChildNode(lvlNode)
        }
    }
    
    func getLevelIconColor(_ level: Int) -> UIColor {
        switch level {
        case 1...3:
            return Constants.Colors.fillColors[8]
        case 4...11:
            return Constants.Colors.fillColors[9]
        case 12:
            return Constants.Colors.fillColors[10]
        default:
            return Constants.Colors.fillColors[6]
        }
    }
    
    func imageWithText(text:String, backgroundColor:UIColor) -> UIImage? {
        let imageSize = CGSize(width: 100, height: 100)
        let imageRect = CGRect(origin: CGPoint.zero, size: imageSize)
        UIGraphicsBeginImageContext(imageSize)
        defer { UIGraphicsEndImageContext() }
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        context.setFillColor(backgroundColor.cgColor)
        context.fill(imageRect)
        if text != "X" {
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .center
            let attributes = [
                NSAttributedString.Key.font: UIFont(name: "TimesNewRomanPS-BoldMT", size: 20),
                NSAttributedString.Key.paragraphStyle: paragraphStyle,
                NSAttributedString.Key.foregroundColor: UIColor.black
            ]
            
            let textSize = text.size(withAttributes: attributes as [NSAttributedString.Key : Any])
            text.draw(at: CGPoint(x: imageSize.width/2 - textSize.width/2, y: imageSize.height/2 - textSize.height/2), withAttributes: attributes as [NSAttributedString.Key : Any])
        }else {
            if let lock = UIImage(named: "art.scnassets/lock-icon.png") {
                let rect = CGRect(origin: CGPoint(x: imageRect.midX - 13, y: imageRect.midY - 18),size: CGSize(width: 26, height: 36))
                lock.draw(in: rect)
            }
        }
        if let image = UIGraphicsGetImageFromCurrentImageContext() {
            return image
        }
        return nil
    }
    
    private func makeSudokuTitle() {
        let title = SCNScene(named: "art.scnassets/Title.dae")!
        guard let geometry = title.rootNode.childNode(withName: "typeMesh1", recursively: true)?.geometry else { return }
        let titleNode = SCNNode(geometry: geometry)
        titleNode.scale = SCNVector3Make(0.8, 0.8, 0.8)
        titleNode.position = SCNVector3(x: -23, y: 0, z: 0)
        titleNode.name = "Title"
        let material = SCNMaterial()
        material.diffuse.contents = Constants.Colors.title
        titleNode.geometry?.firstMaterial = material
        self.addChildNode(titleNode)
    }
    
    public func updateLevel(_ level : Int) {
        currentLevel.string = "Current Level: \(level)"
    }

    public func setAccessible(level: Int, isAccessible: Bool) {
        childNode(withName: "lvl\(level)", recursively: false)?.geometry?.firstMaterial!.diffuse.contents = imageWithText(text: isAccessible ? "\(level)" : "X", backgroundColor: getLevelIconColor(level))
    }
}
