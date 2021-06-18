//
//  ScanCodeView.swift
//  BarcodeReader
//
//  Created by Benjamin Gouguet on 10/07/2018.
//  Copyright © 2018 Benjamin Gouguet. All rights reserved.
//

import UIKit

@IBDesignable
class ScanCodeView: UIView {

    
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        let path = UIBezierPath()
        path.move(to: CGPoint(x: rect.width/2 - 120, y: rect.height/2))
        path.addLine(to: CGPoint(x: rect.width/2 + 120, y: rect.height/2))
        UIColor.red.setStroke()
        path.lineWidth = 4
        path.stroke()
    }
    

}
