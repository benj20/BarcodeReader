//
//  QRCodeViewController.swift
//  QRCodeReader
//
//  Created by Simon Ng on 13/10/2016.
//  Copyright © 2016 AppCoda. All rights reserved.
//

import UIKit

class QRCodeViewController: UIViewController {
    
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var codesLabel: UILabel!
    
    var codes = [Code]() {
        didSet {
            updateView()
        }
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateView()
        startButton.layer.cornerRadius = 27
        startButton.clipsToBounds = true
    }
    
    
    func updateView() {
        var text = ""
        for code in codes {
            text += "\(code.code) -> \(code.name)\n"
        }
        codesLabel.text = text
    }

    
    
    // MARK: - Navigation

    @IBAction func unwindToHomeScreen(segue: UIStoryboardSegue) {
        dismiss(animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showCamera" {
            let nav = segue.destination as! UINavigationController
            let controller = nav.topViewController as! ViewController
            controller.codeList = codes
        }
    }

}
