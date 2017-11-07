//
//  GiphyView.swift
//  Giphy Browser
//
//  Created by Brad G. on 11/7/17.
//  Copyright © 2017 Brad G. All rights reserved.
//

import UIKit

final class GiphyView: UIView {
    
    var color = UIColor.lightGray {
        didSet {
            setNeedsDisplay()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        contentMode = .redraw
        isOpaque = false
        backgroundColor = .clear
    }
    
    override func draw(_ rect: CGRect) {
        color.set()
        let lineWidth = bounds.width * 0.05
        let path = UIBezierPath()
        let margin = bounds.width * 0.15
        let dogEarInset = (bounds.width - margin * 2.0) * 0.333
        path.move(to: CGPoint(x: margin + lineWidth * 0.5, y: lineWidth * 0.5))
        path.addLine(to: CGPoint(x: bounds.maxX - margin - dogEarInset - lineWidth * 0.5, y: lineWidth * 0.5 ))
        path.addLine(to: CGPoint(x: bounds.maxX - margin - dogEarInset - lineWidth * 0.5, y: dogEarInset - lineWidth * 0.5))
        path.addLine(to: CGPoint(x: bounds.maxX - margin - dogEarInset - lineWidth * 0.5, y: dogEarInset - lineWidth * 0.5))
        path.addLine(to: CGPoint(x: bounds.maxX - margin - lineWidth * 0.5, y: dogEarInset - lineWidth * 0.5))
        path.addLine(to: CGPoint(x: bounds.maxX - margin - lineWidth * 0.5, y: bounds.maxY - lineWidth * 0.5))
        path.addLine(to: CGPoint(x: margin + lineWidth * 0.5, y: bounds.maxY - lineWidth * 0.5))
        path.close()
        path.lineWidth = lineWidth
        path.stroke()
        
        let squarePath = UIBezierPath(rect: CGRect(x: bounds.maxX - margin - dogEarInset - lineWidth * 0.5, y: dogEarInset - dogEarInset * 0.5 - lineWidth * 0.5, width: dogEarInset * 0.5, height: dogEarInset * 0.5 - lineWidth * 0.5))
        squarePath.lineWidth = lineWidth
        squarePath.fill()
        squarePath.stroke()
    }
    
    override var collisionBoundsType: UIDynamicItemCollisionBoundsType {
        return UIDynamicItemCollisionBoundsType.path
    }
    
    override var collisionBoundingPath: UIBezierPath {
        let lineWidth = bounds.width * 0.05
        let path = UIBezierPath()
        let margin = bounds.width * 0.15
        let dogEarInset = (bounds.width - margin * 2.0) * 0.333
        path.move(to: CGPoint(x: margin + lineWidth * 0.5 - bounds.midX, y: lineWidth * 0.5 - bounds.midY))
        path.addLine(to: CGPoint(x: bounds.maxX - margin - dogEarInset - lineWidth * 0.5 - bounds.midX, y: lineWidth * 0.5 - bounds.midY))
        path.addLine(to: CGPoint(x: bounds.maxX - margin - dogEarInset - lineWidth * 0.5 - bounds.midX, y: dogEarInset - lineWidth * 0.5 - bounds.midY))
        path.addLine(to: CGPoint(x: bounds.maxX - margin - dogEarInset - lineWidth * 0.5 - bounds.midX, y: dogEarInset - lineWidth * 0.5 - bounds.midY))
        path.addLine(to: CGPoint(x: bounds.maxX - margin - lineWidth * 0.5 - bounds.midX, y: dogEarInset - lineWidth * 0.5 - bounds.midY))
        path.addLine(to: CGPoint(x: bounds.maxX - margin - lineWidth * 0.5 - bounds.midX, y: bounds.maxY - lineWidth * 0.5 - bounds.midY))
        path.addLine(to: CGPoint(x: margin + lineWidth * 0.5 - bounds.midX, y: bounds.maxY - lineWidth * 0.5 - bounds.midY))
        path.close()
        path.lineWidth = lineWidth
        path.stroke()
        return path
    }
}
