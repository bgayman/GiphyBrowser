//
//  SheetContainerViewController.swift
//  Sheet
//
//  Created by B Gay on 11/6/17.
//  Copyright © 2017 B Gay. All rights reserved.
//

import UIKit

/// Container view controller that allows a master view controller to slide over a detail view controller
class SheetContainerViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet private weak var masterContainerView: UIView!
    @IBOutlet private weak var detailContainerView: UIView!
    @IBOutlet private weak var handleView: UIView!
    @IBOutlet private weak var overlayView: UIView!
    @IBOutlet private weak var detailContainerViewBottomConstraint: NSLayoutConstraint!
    
    // MARK: - Properties
    var masterViewController: UIViewController {
        didSet {
            oldValue.removeFromParentViewController()
            add(childViewController: masterViewController, to: masterContainerView, at: 0)
        }
    }
    var detailViewController: UIViewController {
        didSet {
            oldValue.removeFromParentViewController()
            add(childViewController: detailViewController, to: detailContainerView, at: 0)
        }
    }
    
    private let detailContainerCornerRadius: CGFloat = 20
    var bottomConstraintStartView: CGFloat = 64.0
    private var bottomClampOffset: CGFloat = 64.0
    private var topOffset: CGFloat {
        let topInset: CGFloat
        if #available(iOS 11.0, *) {
            topInset = view.safeAreaInsets.top
        }
        else {
            topInset = topLayoutGuide.length
        }
        return topInset + 20.0
    }
    
    // MARK: - Lifecycle
    init(masterViewController: UIViewController, detailViewController: UIViewController) {
        self.masterViewController = masterViewController
        self.detailViewController = detailViewController
        super.init(nibName: "SheetContainerViewController", bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    // MARK: - Setup
    private func setupUI() {
        detailContainerView.layer.cornerRadius = detailContainerCornerRadius
        detailContainerView.layer.masksToBounds = true
        
        handleView.layer.cornerRadius = handleView.bounds.height * 0.5
        handleView.layer.masksToBounds = true
        
        add(childViewController: masterViewController, to: masterContainerView, at: 0)
        add(childViewController: detailViewController, to: detailContainerView, at: 0)
    }
    
    // MARK: - Actions
    @IBAction func handlePan(_ sender: UIPanGestureRecognizer) {
        let velocity = sender.velocity(in: view)
        let translation = sender.translation(in: view)
        switch sender.state
        {
        case .began:
            bottomConstraintStartView = detailContainerViewBottomConstraint.constant
            detailContainerViewBottomConstraint.constant += -translation.y
        case .changed:
            let constraintMax = view.bounds.height - detailContainerCornerRadius
            detailContainerViewBottomConstraint.constant = min(constraintMax, max(bottomClampOffset, bottomConstraintStartView + -translation.y))
            overlayView.alpha = detailContainerViewBottomConstraint.constant / constraintMax
        case .failed, .possible:
            break
        case .cancelled, .ended:
            if velocity.y >= 0
            {
                animateDown()
            }
            else
            {
                animateUp()
            }
        }
    }
    
    @IBAction private func didTapOverlayView(_ sender: UITapGestureRecognizer) {
        animateDown()
    }
    
    // MARK: - Helpers
    private func add(childViewController: UIViewController, to view: UIView, at index: Int) {
        childViewController.view.translatesAutoresizingMaskIntoConstraints = false
        self.addChildViewController(childViewController)
        childViewController.view.frame = view.bounds
        view.insertSubview(childViewController.view, at: index)
        childViewController.view.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        childViewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        childViewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        childViewController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        childViewController.didMove(toParentViewController: self)
    }
    
    private func remove(childViewController: UIViewController) {
        childViewController.willMove(toParentViewController: nil)
        childViewController.removeFromParentViewController()
        childViewController.view.removeFromSuperview()
    }
    
    // MARK: - Animation
    func animateDown()
    {
        UIView.animate(withDuration: 0.5, delay: 0.0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.0, options: [], animations:
            { [unowned self] in
                self.detailContainerViewBottomConstraint.constant = self.bottomClampOffset
                self.overlayView.alpha = 0.0
                self.view.layoutIfNeeded()
        })
    }
    
    func animateUp()
    {
        UIView.animate(withDuration: 0.5, delay: 0.0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.0, options: [], animations:
            { [unowned self] in
                self.detailContainerViewBottomConstraint.constant = self.view.bounds.height - self.topOffset
                self.overlayView.alpha = 1.0
                self.view.layoutIfNeeded()
        })
    }
}

// MARK: - UIViewController+SheetContainerViewController
extension UIViewController {
    var sheetContainerViewController: SheetContainerViewController? {
        if let sheetVC = parent as? SheetContainerViewController {
            return sheetVC
        }
        return navigationController?.parent as? SheetContainerViewController
    }
}
