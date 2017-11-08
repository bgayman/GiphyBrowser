//
//  MagicMoveAnimator.swift
//  Giphy Browser
//
//  Created by Brad G. on 11/7/17.
//  Copyright © 2017 Brad G. All rights reserved.
//

import UIKit
import SDWebImage

// MARK: - Protocols
protocol MagicMoveFromViewControllerDataSource: class {
    var fromMagicView: FLAnimatedImageView? { get }
    var fromURL: URL? { get }
}

protocol MagicMoveToViewControllerDataSource: class {
    var toMagicView: FLAnimatedImageView { get }
    var chromeViews: [UIView] { get }
    var toURL: URL? { get }
}

final class MagicMoveAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
    // MARK: - Properties
    let isAppearing: Bool
    let duration: TimeInterval
    
    // MARK: - Lifecycle
    init(isAppearing: Bool, duration: TimeInterval = 0.3) {
        self.isAppearing =  isAppearing
        self.duration = duration
        super.init()
    }
    
    // MARK: - UIViewControllerAnimatedTransitioning
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        if isAppearing {
            animateOn(transitionContext)
        } else {
            animateOff(transitionContext)
        }
    }
    
    // MARK: - Animations
    func animateOn(_ transitionContext: UIViewControllerContextTransitioning) {
        let fromVC = transitionContext.viewController(forKey: .from)!
        let toVC = transitionContext.viewController(forKey: .to)!
        let container = transitionContext.containerView
        
        guard let fromDataSource = fromVC as? MagicMoveFromViewControllerDataSource else {
            return
        }
        
        guard let toDataSource = toVC as? MagicMoveToViewControllerDataSource else {
            return
        }
        
        toVC.view.alpha = 0.0
        let finalFrame = transitionContext.finalFrame(for: toVC)
        var frame = finalFrame
        frame.origin.y += frame.size.height
        toVC.view.frame = frame
        toVC.view.layoutIfNeeded()
        container.addSubview(toVC.view)
        
        let backdrop = UIView(frame: toVC.view.frame)
        backdrop.backgroundColor = toVC.view.backgroundColor
        backdrop.alpha = 0.0
        container.addSubview(backdrop)
        toVC.view.backgroundColor = .clear
        
        let fromMagicView = fromDataSource.fromMagicView
        let toMagicView = toDataSource.toMagicView
        toDataSource.chromeViews.forEach { $0.alpha = 0.0}
        let snapshot = FLAnimatedImageView()
        snapshot.contentMode = fromMagicView?.contentMode ?? .scaleAspectFit
        snapshot.clipsToBounds = true
        snapshot.backgroundColor = backdrop.backgroundColor
        snapshot.sd_setImage(with: fromDataSource.fromURL)
        let rect = container.convert(fromMagicView?.bounds ?? .zero, from: fromMagicView)
        snapshot.frame = rect
        container.addSubview(snapshot)
        
        fromMagicView?.isHidden = true
        toMagicView.isHidden = true
        
        UIView.animate(withDuration: duration, animations: {
            backdrop.alpha = 1.0
            toVC.view.alpha = 1.0
            toDataSource.chromeViews.forEach { $0.alpha = 1.0 }
            toVC.view.frame = finalFrame
            snapshot.frame = container.convert(toMagicView.bounds, from: toMagicView)
            
        }) { (finished) in
            toVC.view.backgroundColor = backdrop.backgroundColor
            backdrop.removeFromSuperview()
            
            fromMagicView?.isHidden = false
            toMagicView.isHidden = false
            snapshot.removeFromSuperview()
            
            transitionContext.completeTransition(finished)
        }
    }
    
    func animateOff(_ transitionContext: UIViewControllerContextTransitioning) {
        let fromVC = transitionContext.viewController(forKey: .from)!
        let toVC = transitionContext.viewController(forKey: .to)!
        let container = transitionContext.containerView
        
        // Animating off so we need to reverse data sources
        guard let fromDataSource = fromVC as? MagicMoveToViewControllerDataSource else {
            return
        }
        guard let toDataSource = toVC as? MagicMoveFromViewControllerDataSource else {
            return
        }
        
        let fromMagicView = fromDataSource.toMagicView
        let toMagicView = toDataSource.fromMagicView
        
        let backdrop = UIView(frame: fromVC.view.frame)
        backdrop.backgroundColor = fromVC.view.backgroundColor
        container.insertSubview(backdrop, belowSubview: fromVC.view)
        backdrop.alpha = 1.0
        fromVC.view.backgroundColor = .clear
        
        let snapshot = FLAnimatedImageView()
        snapshot.contentMode = fromMagicView.contentMode
        snapshot.clipsToBounds = true
        snapshot.sd_setImage(with: toDataSource.fromURL)
        fromMagicView.isHidden = true
        snapshot.frame = container.convert(fromMagicView.bounds, from: fromMagicView)
        container.addSubview(snapshot)
        
        let finalFrame = transitionContext.finalFrame(for: toVC)
        toVC.view.frame = finalFrame
        
        var frame = finalFrame
        frame.origin.y += frame.size.height
        
        UIView.animate(withDuration: duration - 0.1, animations: {
            backdrop.alpha = 0
            fromDataSource.chromeViews.forEach { $0.alpha = 0.0 }
            fromVC.view.frame = frame
            snapshot.frame = container.convert(toMagicView?.bounds ?? .zero, from: toMagicView)
            toVC.view.frame = finalFrame
            toVC.view.alpha = 1.0
        }) { (_) in
            fromVC.view.backgroundColor = backdrop.backgroundColor
            backdrop.removeFromSuperview()
            snapshot.removeFromSuperview()
            fromDataSource.chromeViews.forEach { $0.alpha = 1.0 }
            
            fromMagicView.isHidden = false
            toMagicView?.isHidden = false
            
            let wasCancelled = transitionContext.transitionWasCancelled
            transitionContext.completeTransition(!wasCancelled)
        }
    }
    
}
