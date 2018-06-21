//
//  Arrow.swift
//  Thattaway
//
//  Created by Chris Dalldorf on 6/19/18.
//  Copyright © 2018 Chris Dalldorf. All rights reserved.
//

import UIKit

class Arrow: UIView {
    var distRatio = 1.0 {
        didSet {
            setNeedsDisplay()
        }
    }
    
    var rotationAngle = Double.pi / 4 {
        didSet {
            setNeedsDisplay()
        }
    }

    
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        let path = UIBezierPath()
        path.move(to: CGPoint(x: rect.width/2,y: 0))
        path.addLine(to: CGPoint(x: rect.width,y: rect.height/2))
        path.addLine(to: CGPoint(x: 3*rect.width/4,y: rect.height/2))
        path.addLine(to: CGPoint(x: 3*rect.width/4,y: rect.height))
        path.addLine(to: CGPoint(x: rect.width/4, y: rect.height))
        path.addLine(to: CGPoint(x: rect.width/4, y: rect.height/2))
        path.addLine(to: CGPoint(x: 0, y: rect.height/2))
        path.close()
        path.addClip()
        
    
        UIView.animate(withDuration: 1.0, animations: { () in
            self.transform = CGAffineTransform(rotationAngle: CGFloat(self.rotationAngle))
            let color = UIColor(displayP3Red: CGFloat(1-self.distRatio), green: 0.0, blue: CGFloat(self.distRatio), alpha: 0.7)
            color.setStroke()
            color.setFill()
            path.stroke()
            path.fill()
        } )
        //print("new = \(self.rotationAngle), old = \(self.oldAngle)")
    }
}
