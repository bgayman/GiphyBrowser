//
//  SearchEmptyStateViewController.swift
//  Giphy Browser
//
//  Created by B Gay on 11/9/17.
//  Copyright © 2017 Brad G. All rights reserved.
//

import UIKit
import CoreMotion


class SearchEmptyStateViewController: UIViewController {

    // MARK: - Outlets
    @IBOutlet private var mainEmptyStateView: MagnifyingGlassView!
    @IBOutlet private var emptyStateLabel: UILabel!
    
    // MARK: - Properties
    let motionManager = CMMotionManager()

    // MARK: - Lazy Inits
    lazy private var dynamicAnimator: UIDynamicAnimator = {
        let dynamicAnimator = UIDynamicAnimator(referenceView: self.view)
        return dynamicAnimator
    }()
    
    lazy private var gravity: UIGravityBehavior = {
        let gravity = UIGravityBehavior(items: dynamicItems)
        gravity.magnitude = 2.0
        return gravity
    }()
    
    lazy private var collision: UICollisionBehavior = {
        let inset = UIEdgeInsets(top: 0, left: 0, bottom: (self.sheetContainerViewController?.topOffset ?? 0), right: 0)
        let dynamicViews: [UIDynamicItem] = giphyViews as [UIDynamicItem] + magnifyingGlassViews as [UIDynamicItem]
        let collision = UICollisionBehavior(items: dynamicViews)
        return collision
    }()
    
    lazy private var mainAttachmentBehavior: UIAttachmentBehavior = {
        let mainAttachmentBehavior = UIAttachmentBehavior(item: self.mainEmptyStateView, attachedToAnchor: CGPoint(x: self.view.center.x, y: self.view.center.y - (self.sheetContainerViewController?.topOffset ?? 0.0) - 20.0))
        mainAttachmentBehavior.length = 0.0
        return mainAttachmentBehavior
    }()
    
    lazy private var labelAttachmentBehavior: UIAttachmentBehavior = {
        let labelAttachmentBehavior = UIAttachmentBehavior.limitAttachment(with: self.mainEmptyStateView, offsetFromCenter: .zero, attachedTo: self.emptyStateLabel, offsetFromCenter: .zero)
        labelAttachmentBehavior.length = self.mainEmptyStateView.bounds.midY + self.emptyStateLabel.bounds.midY + 15.0
        labelAttachmentBehavior.damping = 1.0
        return labelAttachmentBehavior
    }()
    
    lazy private var itemBehavior: UIDynamicItemBehavior = {
        let itemBehavior = UIDynamicItemBehavior(items: [self.mainEmptyStateView, self.emptyStateLabel])
        itemBehavior.allowsRotation = false
        itemBehavior.angularResistance = 6.0
        itemBehavior.resistance = 2.0
        itemBehavior.density = 2.0
        return itemBehavior
    }()
    
    lazy private var magnifyingGlassItemBehavior: UIDynamicItemBehavior = {
        let items: [UIDynamicItem] = self.magnifyingGlassViews as [UIDynamicItem] + self.giphyViews as [UIDynamicItem]
        let itemBehavior = UIDynamicItemBehavior(items: items)
        itemBehavior.allowsRotation = true
        itemBehavior.elasticity = 0.4
        itemBehavior.angularResistance = 5
        return itemBehavior
    }()
    
    lazy var magnifyingGlassViews: [MagnifyingGlassView] = {
        var magnifyingGlassViews = [MagnifyingGlassView]()
        for _ in 0 ..< 60 {
            let magnifyingGlassView = MagnifyingGlassView(frame: .zero)
            self.view.addSubview(magnifyingGlassView)
            magnifyingGlassViews.append(magnifyingGlassView)
        }
        return magnifyingGlassViews
    }()
    
    lazy var giphyViews: [GiphyView] = {
        var giphyViews = [GiphyView]()
        for _ in 0 ..< 20 {
            let giphyView = GiphyView(frame: .zero)
            self.view.addSubview(giphyView)
            giphyViews.append(giphyView)
        }
        return giphyViews
    }()
    
    // MARK: - Computed Properties
    var dynamicItems: [UIDynamicItem] {
        return magnifyingGlassViews as [UIDynamicItem] + [mainEmptyStateView, emptyStateLabel] as [UIDynamicItem] + giphyViews as [UIDynamicItem]
    }
    
    var ovalCollisionPath: UIBezierPath {
        let rect = view.convert(mainEmptyStateView.ovalRect, from: mainEmptyStateView)
        let ovalPath = UIBezierPath(ovalIn: rect)
        ovalPath.lineWidth = mainEmptyStateView.lineWidth
        return ovalPath
    }
    
    var lineCollisionPath: UIBezierPath {
        let linePath = UIBezierPath()
        let startPoint = view.convert(mainEmptyStateView.startPoint, from: mainEmptyStateView)
        linePath.move(to: startPoint)
        let endPoint = mainEmptyStateView.convert(mainEmptyStateView.endPoint, to: view)
        linePath.addLine(to: endPoint)
        linePath.lineWidth = mainEmptyStateView.lineLineWidth
        return linePath
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        mainEmptyStateView.frame = CGRect(x: view.center.x, y: view.bounds.minY + 100.0, width: min(425, view.bounds.width - 100), height: min(425, view.bounds.width - 100))
        mainEmptyStateView.center = CGPoint(x: view.center.x, y: 100 + mainEmptyStateView.bounds.height * 0.5)
        dynamicAnimator.updateItem(usingCurrentState: mainEmptyStateView)
        mainAttachmentBehavior.anchorPoint = mainEmptyStateView.center
        updateBoundries()
    }

    // MARK: - Setup
    private func setupUI() {
        mainEmptyStateView.translatesAutoresizingMaskIntoConstraints = true
        mainEmptyStateView.color = UIColor.appBlue
        view.addSubview(mainEmptyStateView)
        emptyStateLabel.font = UIFont.appFont(textStyle: .title2, weight: .medium)
        emptyStateLabel.textColor = .appBlue
        emptyStateLabel.numberOfLines = 0
        emptyStateLabel.translatesAutoresizingMaskIntoConstraints = true
        emptyStateLabel.center = CGPoint(x: view.bounds.midX, y: view.bounds.maxY - 100.0)
        emptyStateLabel.sizeToFit()
        view.addSubview(emptyStateLabel)
        
        updateViews()
        
        dynamicAnimator.addBehavior(gravity)
        dynamicAnimator.addBehavior(collision)
        dynamicAnimator.addBehavior(mainAttachmentBehavior)
        dynamicAnimator.addBehavior(labelAttachmentBehavior)
        dynamicAnimator.addBehavior(itemBehavior)
        dynamicAnimator.addBehavior(magnifyingGlassItemBehavior)
        motionManager.startDeviceMotionUpdates(to: OperationQueue.main, withHandler: gravityUpdated)
    }
    
    // MARK: - Core Motion
    @objc private func gravityUpdated(motion: CMDeviceMotion?, error: Error?) {
        
        guard let motion = motion else { return }
        let grav: CMAcceleration = motion.gravity;
        
        let x = CGFloat(grav.x)
        let y = CGFloat(grav.y)
        var p = CGPoint(x: x, y: y)
        
        let orientation = UIApplication.shared.statusBarOrientation;
        
        if orientation == UIInterfaceOrientation.landscapeRight {
            let t = p.x
            p.x = 0 - p.y
            p.y = t
        }
        else if orientation == UIInterfaceOrientation.landscapeLeft {
            let t = p.x
            p.x = p.y
            p.y = 0 - t
        }
        else if orientation == UIInterfaceOrientation.portraitUpsideDown {
            p.x = p.x * -1
            p.y = p.y * -1
        }
        
        let v = CGVector(dx: p.x, dy: 0 - p.y)
        gravity.gravityDirection = v
    }
    
    // MARK: - Helpers
    private func arrange(_ views: [UIView]) {
        views.forEach {
            let size: CGFloat = CGFloat(arc4random() % 50 + 20)
            let x: CGFloat = CGFloat(arc4random() % UInt32(self.view.bounds.width - 100) + 50)
            let y: CGFloat = CGFloat(arc4random() % UInt32(self.view.bounds.height * 0.5 + 50) + UInt32(self.view.bounds.height * 0.5))
            $0.frame = CGRect(x: x, y: y, width: size, height: size)
            self.dynamicAnimator.updateItem(usingCurrentState: $0)
        }
    }
    
    private func updateBoundries() {
        collision.removeAllBoundaries()
        let inset = UIEdgeInsets(top: 0, left: 0, bottom: (self.sheetContainerViewController?.topOffset ?? 0), right: 0)
        collision.setTranslatesReferenceBoundsIntoBoundary(with: inset)
        collision.addBoundary(withIdentifier: "ovalCollisionPath" as NSString, for: ovalCollisionPath)
        collision.addBoundary(withIdentifier: "lineCollisionPath" as NSString, for: lineCollisionPath)
    }
    
    private func updateViews() {
        arrange(giphyViews)
        arrange(magnifyingGlassViews)
    }
}
