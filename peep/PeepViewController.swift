//
//  PeepViewController.swift
//  peep
//
//  Created by Riley Rodenburg on 2/17/17.
//  Copyright © 2017 buddhabuddha. All rights reserved.
//

import UIKit

class PeepViewController: UIViewController {

    @IBOutlet var connectionsLabel: UILabel!
    
    let peepService = PeepServiceManager()
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        peepService.delegate = self
        
    }

    @IBAction func redTapped(_ sender: Any) {
        
        self.change(color: .red)
        peepService.send(colorName: "red")
        
    }
    
    @IBAction func yellowTapped(_ sender: Any) {
        
        self.change(color: .yellow)
        peepService.send(colorName: "yellow")
        
    }
    
    func change(color : UIColor) {
        
        UIView.animate(withDuration: 0.5) {
            self.view.backgroundColor = color
        }
        
    }
    
}

extension PeepViewController : PeepServiceManagerDelegate {
    
    func connectedDevicesChanged(manager: PeepServiceManager, connectedDevices: [String]) {
        OperationQueue.main.addOperation {
            print("CHANGED.")
            self.connectionsLabel.text = "Connections: \(connectedDevices)"
        }
    }
    
    func colorChanged(manager: PeepServiceManager, colorString: String) {
        OperationQueue.main.addOperation {
            switch colorString {
            case "red":
                self.change(color: .red)
            case "yellow":
                self.change(color: .yellow)
            default:
                NSLog("%@", "Unknown color value received: \(colorString)")
            }
        }
    }
    
}
