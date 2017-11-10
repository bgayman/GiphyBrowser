//
//  SheetContainerViewController.swift
//  Sheet
//
//  Created by B Gay on 11/6/17.
//  Copyright © 2017 B Gay. All rights reserved.
//

import UIKit
import SDWebImage

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
            remove(childViewController: oldValue)
            add(childViewController: masterViewController, to: masterContainerView, at: 0)
        }
    }
    var detailViewController: UIViewController {
        didSet {
            remove(childViewController: oldValue)
            add(childViewController: detailViewController, to: detailContainerView, at: 0)
        }
    }
    
    private let detailContainerCornerRadius: CGFloat = 20
    var bottomConstraintStartView: CGFloat = 64.0
    private var bottomClampOffset: CGFloat = 64.0
    private var orientation = UIApplication.shared.statusBarOrientation
    var topOffset: CGFloat {
        let topInset: CGFloat
        if #available(iOS 11.0, *) {
            topInset = view.safeAreaInsets.top
        }
        else {
            topInset = topLayoutGuide.length
        }
        return topInset + 20.0
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
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
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if orientation != UIApplication.shared.statusBarOrientation {
            orientation = UIApplication.shared.statusBarOrientation
            animateDown()
        }
    }
    
    // MARK: - Setup
    private func setupUI() {
        detailContainerView.layer.cornerRadius = detailContainerCornerRadius
        detailContainerView.layer.masksToBounds = true
        detailContainerView.layer.borderWidth = 1.0 / UIScreen.main.scale
        detailContainerView.layer.borderColor = UIColor.lightGray.cgColor
        
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
    
    // MARK: - Animation
    func animateDown()
    {
        detailViewController.view.endEditing(true)
        UIView.animate(withDuration: 0.5, delay: 0.0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.0, options: [.allowUserInteraction], animations:
            { [unowned self] in
                self.detailContainerViewBottomConstraint.constant = self.bottomClampOffset
                self.overlayView.alpha = 0.0
                self.view.layoutIfNeeded()
        })
    }
    
    func animateUp()
    {
        UIView.animate(withDuration: 0.5, delay: 0.0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.0, options: [.allowUserInteraction], animations:
            { [unowned self] in
                let bottomInset: CGFloat
                if #available(iOS 11.0, *) {
                    bottomInset = self.view.safeAreaInsets.bottom
                }
                else {
                    bottomInset = self.bottomLayoutGuide.length
                }
                self.detailContainerViewBottomConstraint.constant = self.view.bounds.height - self.topOffset - bottomInset
                self.overlayView.alpha = 1.0
                self.view.layoutIfNeeded()
        }) { [unowned self] (_) in
            if let navVC = self.detailViewController as? UINavigationController,
               let searchViewController = navVC.topViewController as? SearchViewController {
                searchViewController.searchController.searchBar.becomeFirstResponder()
            }
        }
    }
    
    func setSheetHidden(hidden: Bool, animated: Bool = true) {
        if animated {
            if hidden {
                detailViewController.view.endEditing(true)
                UIView.animate(withDuration: 0.2, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.0, options: [.allowUserInteraction], animations:
                    { [unowned self] in
                        if #available(iOS 11.0, *) {
                            self.detailContainerViewBottomConstraint.constant = -self.view.safeAreaInsets.bottom
                        }
                        else {
                            self.detailContainerViewBottomConstraint.constant = -self.bottomLayoutGuide.length
                        }
                        self.view.layoutIfNeeded()
                })
            }
            else {
                animateDown()
            }
        }
        else {
            detailContainerViewBottomConstraint.constant = bottomClampOffset
            overlayView.alpha = 0.0
        }
    }
}

// MARK: - MagicMoveFromViewControllerDataSource
extension SheetContainerViewController: MagicMoveFromViewControllerDataSource {
    
    var fromMagicView: FLAnimatedImageView? {
        guard let navController = masterViewController as? UINavigationController,
              let dataSource = navController.viewControllers.first as? MagicMoveFromViewControllerDataSource else { return nil }
        return dataSource.fromMagicView
    }
    
    var fromURL: URL? {
        guard let navController = masterViewController as? UINavigationController,
            let dataSource = navController.viewControllers.first as? MagicMoveFromViewControllerDataSource else { return nil }
        return dataSource.fromURL
    }
    
}

// MARK: - UIViewController+SheetContainerViewController
extension UIViewController {
    var sheetContainerViewController: SheetContainerViewController? {
        if let sheetVC = parent as? SheetContainerViewController {
            return sheetVC
        }
        if let sheetVC = navigationController?.parent as? SheetContainerViewController {
            return sheetVC
        }
        return parent?.sheetContainerViewController
    }
}
