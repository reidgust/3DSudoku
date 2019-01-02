//
//  AlertManager.swift
//  Sudoku3D
//
//  Created by Reid on 2019-01-01.
//  Copyright © 2019 Reid. All rights reserved.
//

import Foundation
import UIKit

class AlertManager {
    let delegate : GameViewController
    
    init(caller : GameViewController) {
        delegate = caller
    }

    func presentTipAlert(withMessage message : String, withTitle title : String = "", dismissButton : String = "That's cool.") {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: dismissButton, style: .cancel, handler: nil))
        delegate.present(alert, animated: true)
    }

    func presentActionSheet(withMessage message: String, currentLevel : Bool = false, random : Bool = false) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .actionSheet)
        alert.popoverPresentationController?.sourceView = delegate.view!
        alert.addAction(UIAlertAction(title: "Continue Current Level", style: .cancel, handler: nil))
        if currentLevel {
            alert.addAction(UIAlertAction(title: "Reset Level", style: .default, handler: { action in
                self.delegate.resetCube()
            }))
            if random {
                alert.addAction(UIAlertAction(title: "New Random Level", style: .default, handler: { action in
                    self.delegate.randomLevel()
                }))
            }
        }
        if !UserDefaults.standard.bool(forKey: "hasPaid") {
            alert.addAction(UIAlertAction(title:"Upgrade For Unlimited Levels", style: .default, handler: { action in
                self.delegate.purchaseRequest()
            }))
        }
        
        delegate.present(alert, animated: true)
    }

    func responseToPurchaseRequest(success: Bool, message : String) {
        if success {
            let alert = UIAlertController(title: "Upgrade", message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "No thanks.", style: .cancel, handler: nil))
            alert.addAction(UIAlertAction(title: "Upgrade!", style: .default, handler: { click in
                self.delegate.buyProduct()
            }))
            delegate.present(alert, animated: true)
        } else {
            presentTipAlert(withMessage: message, withTitle: "Unable To Upgrade", dismissButton: "OH NO!")
        }
    }
}
