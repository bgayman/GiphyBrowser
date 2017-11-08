//
//  GiphyDetailViewController.swift
//  Giphy Browser
//
//  Created by Brad G. on 11/7/17.
//  Copyright © 2017 Brad G. All rights reserved.
//

import UIKit
import SDWebImage

class GiphyDetailViewController: UIViewController {

    // MARK: - Properties
    let giphy: Giphy
    let colorArt: ColorArt?
    var isPeeking = false
    
    // MARK: - Computed Properties
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return  colorArt?.backgroundColor.isDarkColor == true ? .lightContent : .default
    }
    
    override var previewActionItems: [UIPreviewActionItem] {
        let shareActionItem = UIPreviewAction(title: "Share GIF", style: .default) { _, viewController in
            guard let viewController = viewController as? GiphyDetailViewController,
                  let data = viewController.imageView?.animatedImage?.data else { return }
            let controller = UIActivityViewController(activityItems: [data], applicationActivities: nil)
            UIApplication.shared.keyWindow?.rootViewController?.present(controller, animated: true)
        }
        return [shareActionItem]
    }
    
    // MARK: - Lazy Inits
    lazy var dismissDownInteractiveController: PanInteractionController = {
        let dismissDownInteractiveController = PanInteractionController()
        dismissDownInteractiveController.panDirection = .down
        dismissDownInteractiveController.delegate = self
        return dismissDownInteractiveController
    }()
    
    lazy var dismissUpInteractiveController: PanInteractionController = {
        let dismissUpInteractiveController = PanInteractionController()
        dismissUpInteractiveController.panDirection = .up
        dismissUpInteractiveController.delegate = self
        return dismissUpInteractiveController
    }()
    
    let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        return dateFormatter
    }()
    
    // MARK: - Outlets
    @IBOutlet private weak var imageView: FLAnimatedImageView!
    @IBOutlet private weak var closeButton: UIButton!
    @IBOutlet private weak var actionButton: UIButton!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var uploadDateLabel: UILabel!
    
    // MARK: - Lifecycle
    init(giphy: Giphy, colorArt: ColorArt?) {
        self.giphy = giphy
        self.colorArt = colorArt
        super.init(nibName: "GiphyDetailViewController", bundle: nil)
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
        chromeViews.forEach { $0.isHidden = isPeeking }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        animateOnChrome(views: chromeViews)
    }
    
    // MARK: - Setup
    private func setupUI() {
        view.backgroundColor = colorArt?.backgroundColor ?? .appBeige
        
        imageView.sd_setImage(with: giphy.images[GiphyViewModel.listImageType.rawValue]?.url)
        
        let url = giphy.images[GiphyImageType.original.rawValue]?.url
        imageView.sd_setImage(with: url)
        
        let tintColor: UIColor = colorArt?.backgroundColor.isDarkColor == true ? .white : .black
        let font = UIFont.appFont(textStyle: .title3, weight: .bold)
        
        titleLabel.text = giphy.title.capitalized
        uploadDateLabel.text = "Uploaded on\n\(dateFormatter.string(from: giphy.importDate))"
        
        [titleLabel, uploadDateLabel].forEach {
            $0?.textColor = tintColor
            $0?.font = font
            $0?.transform = CGAffineTransform(translationX: 0, y: 100)
        }
        
        [closeButton, actionButton].forEach {
            $0?.tintColor = tintColor
            $0?.transform = CGAffineTransform(translationX: 0, y: -100)
        }
        
        dismissDownInteractiveController.attach(to: view)
        dismissUpInteractiveController.attach(to: view)
    }
    
    // MARK: - Actions
    @IBAction private func didPressClose(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    
    @IBAction private func didPressAction(_ sender: UIButton) {
        guard let data = imageView.animatedImage?.data else { return }
        let activityController = UIActivityViewController(activityItems: [data as Any], applicationActivities: nil)
        activityController.popoverPresentationController?.sourceView = sender
        activityController.popoverPresentationController?.sourceRect = sender.bounds
        present(activityController, animated: true)
    }
    
    // MARK: - Animation
    private func animateOnChrome(views: [UIView]) {
        UIView.animate(withDuration: 0.5, delay: 0.0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.0, options: [.allowUserInteraction], animations: {
            views.forEach { $0.transform = .identity }
        })
    }
}

// MARK: - PanInteractionController
extension GiphyDetailViewController: PanInteractionControllerDelegate {
    
    func interactiveAnimationDidStart(controller: PanInteractionController) {
        dismiss(animated: true)
    }
    
}

// MARK: - MagicMoveToViewControllerDataSource
extension GiphyDetailViewController: MagicMoveToViewControllerDataSource {
    
    var toMagicView: FLAnimatedImageView {
        return imageView
    }
    
    var chromeViews: [UIView] {
        return [closeButton, actionButton, titleLabel, uploadDateLabel]
    }
    
    var toURL: URL? {
        return giphy.images[GiphyImageType.original.rawValue]?.url
    }
    
}

// MARK: - UIViewControllerTransitioningDelegate
extension GiphyDetailViewController: UIViewControllerTransitioningDelegate {
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return MagicMoveAnimator(isAppearing: true)
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if dismissUpInteractiveController.isActive {
            return MagicMoveAnimator(isAppearing: false, direction: .down)
        }
        if dismissDownInteractiveController.isActive {
            return MagicMoveAnimator(isAppearing: false, direction: .up)
        }
        return MagicMoveAnimator(isAppearing: false)
    }
    
    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        if dismissUpInteractiveController.isActive {
            return dismissUpInteractiveController
        }
        if dismissDownInteractiveController.isActive {
            return dismissDownInteractiveController
        }
        return nil
    }
    
    func interactionControllerForPresentation(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return nil
    }
}
