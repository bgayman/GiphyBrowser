//
//  MagnifyingGlassView.swift
//  Giphy Browser
//
//  Created by Brad G. on 11/7/17.
//  Copyright © 2017 Brad G. All rights reserved.
//

import UIKit

final class MagnifyingGlassView: UIView {
    
    var lineWidth: CGFloat {
        return bounds.width * 0.05
    }
    var lineLineWidth: CGFloat {
        let lineLineWidth = lineWidth * 1.75
        return lineLineWidth
    }
    
    var ovalRect: CGRect {
        return CGRect(x: 0.0, y: 0.0, width: radius * 2.0, height: radius * 2.0)
    }
    
    var radius: CGFloat {
        let radius = bounds.width * 0.75 * 0.5
        return radius
    }
    
    var startPoint: CGPoint {
        return CGPoint(x: radius + radius / sqrt(2), y: radius + radius / sqrt(2))
    }
    
    var endPoint: CGPoint {
        
        let endPoint = CGPoint(x: bounds.maxX - lineLineWidth * 0.5, y: bounds.maxY - lineLineWidth * 0.5)
        return endPoint
    }
    
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
        color.setStroke()
        
        let ovalPath = UIBezierPath(ovalIn: ovalRect.insetBy(dx: lineWidth * 0.5, dy: lineWidth * 0.5))
        ovalPath.lineWidth = lineWidth
        ovalPath.stroke()
        
        let lineLineWidth = lineWidth * 1.75
        let linePath = UIBezierPath()
        linePath.move(to: startPoint)
        linePath.addLine(to: endPoint)
        linePath.lineWidth = lineLineWidth
        linePath.lineCapStyle = .round
        linePath.stroke()
    }
    
    override var collisionBoundsType: UIDynamicItemCollisionBoundsType {
        return UIDynamicItemCollisionBoundsType.path
    }
    
    override var collisionBoundingPath: UIBezierPath {
        let radius = bounds.width * 0.75 * 0.5
        let path = UIBezierPath()
        let ovalRect = CGRect(x: -bounds.midX, y: -bounds.midY, width: radius * 2.0, height: radius * 2.0)
        let ovalPath = UIBezierPath(ovalIn: ovalRect)
        let linePath = UIBezierPath()
        let startPoint = CGPoint(x: radius + radius / sqrt(2) - bounds.midX, y: radius + radius / sqrt(2) - bounds.midY)
        linePath.move(to: startPoint)
        let endPoint = CGPoint(x: bounds.maxX - lineWidth * 0.5 - bounds.midX, y: bounds.maxY - lineWidth * 0.5 - bounds.midY)
        linePath.addLine(to: endPoint)
        path.append(ovalPath)
        path.append(linePath)
        path.lineWidth = lineWidth
        path.lineCapStyle = .round
        return path
    }
}
