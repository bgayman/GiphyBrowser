//
//  GiphyListViewController.swift
//  Giphy Browser
//
//  Created by Brad G. on 11/4/17.
//  Copyright © 2017 Brad G. All rights reserved.
//

import UIKit
import SDWebImage
import MobileCoreServices

/// A view controller that displays GIFs in a scrolling list
final class GiphyListViewController: UIViewController, StoryboardInitializable {
    
    // MARK: - Outlets
    @IBOutlet private weak var collectionView: UICollectionView!
    @IBOutlet private weak var statusBarOverlayView: UIView!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    
    // MARK: - Properties
    private var previousScrollViewYOffset: CGFloat = 0.0
    private var selectedImageView: FLAnimatedImageView?
    private var selectedURL: URL?
    var viewModel = GiphyViewModel(contentType: .trending) {
        didSet {
            viewModel.delegate = self
            title = viewModel.title
            collectionView?.reloadData()
            refresh.beginRefreshing()
            navigationItem.setRightBarButtonItems((viewModel.contentType != .trending) ? [trendingBarButtonItem, actionBarButtonItem] : [actionBarButtonItem], animated: true)
        }
    }
    
    // MARK: - Computed Properties
    override var previewActionItems: [UIPreviewActionItem] {
        let shareActionItem = UIPreviewAction(title: "Share", style: .default) { _, viewController in
            guard let viewController = viewController as? GiphyListViewController,
                  let url = viewController.viewModel.shareURL else { return }
            let controller = UIActivityViewController(activityItems: [url], applicationActivities: nil)
            UIApplication.shared.keyWindow?.rootViewController?.present(controller, animated: true)
        }
        return [shareActionItem]
    }
    
    // MARK: - Lazy Inits
    lazy var refresh: UIRefreshControl = {
       let refresh = UIRefreshControl()
        refresh.addTarget(self, action: #selector(self.refresh(_:)), for: .valueChanged)
        return refresh
    }()
    
    lazy var trendingBarButtonItem: UIBarButtonItem = {
        let trendingBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "icTrending"), style: .plain, target: self, action: #selector(self.didPressTrending(_:)))
        return trendingBarButtonItem
    }()
    
    lazy var actionBarButtonItem: UIBarButtonItem = {
        let actionBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "icAction"), style: .plain, target: self, action: #selector(self.didPressAction(_:)))
        return actionBarButtonItem
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.delegate = self
        setupUI()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if traitCollection.horizontalSizeClass == .regular && traitCollection.verticalSizeClass == .regular {
            if #available(iOS 11.0, *) {
                navigationController?.navigationBar.prefersLargeTitles = false
                additionalSafeAreaInsets = .zero
            }
        }
        else {
            if #available(iOS 11.0, *) {
                additionalSafeAreaInsets = UIEdgeInsets(top: 0, left: 0, bottom: self.sheetContainerViewController?.bottomConstraintStartView ?? 0, right: 0)
            }
            else {
                collectionView.contentInset = UIEdgeInsets(top: collectionView.contentInset.top, left: collectionView.contentInset.left, bottom: self.sheetContainerViewController?.bottomConstraintStartView ?? 0, right: collectionView.contentInset.right)
            }
        }
    }
    
    // MARK: - Setup
    private func setupUI() {
        view.backgroundColor = UIColor.appBeige
        statusBarOverlayView.backgroundColor = UIColor.appBeige.withAlphaComponent(0.75)
        
        title = viewModel.title
        
        if #available(iOS 11.0, *) {
            navigationController?.navigationBar.prefersLargeTitles = true
            navigationController?.navigationItem.largeTitleDisplayMode = .always
            navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedStringKey.font: UIFont.appFont(weight: .black, pointSize: 40.0)]
            collectionView.addInteraction(UIDropInteraction(delegate: self))
            collectionView.dragDelegate = self
        }
        else {
            navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.font: UIFont.appFont(weight: .medium, pointSize: 23.0)]
        }
        navigationController?.hidesBarsOnSwipe = true
        navigationController?.navigationBar.barTintColor = UIColor.appBeige
        navigationController?.navigationBar.tintColor = UIColor.appRed
        
        if #available(iOS 10.0, *) {
            collectionView.refreshControl = refresh
        } else {
            collectionView.addSubview(refresh)
        }
        
        navigationItem.setRightBarButtonItems((viewModel.contentType != .trending) ? [trendingBarButtonItem, actionBarButtonItem] : [actionBarButtonItem], animated: true)
        
        activityIndicator.startAnimating()
        
        if traitCollection.forceTouchCapability == .available {
            registerForPreviewing(with: self, sourceView: collectionView)
        }
    }
    
    // MARK: - Actions
    @objc private func refresh(_ sender: UIRefreshControl) {
        viewModel.refresh()
    }
    
    @objc private func didPressTrending(_ sender: UIBarButtonItem) {
        viewModel = GiphyViewModel(contentType: .trending)
    }
    
    @objc private func didPressAction(_ sender: UIBarButtonItem) {
        guard let shareURL = viewModel.shareURL else { return }
        let activityViewController = UIActivityViewController(activityItems: [shareURL], applicationActivities: nil)
        activityViewController.popoverPresentationController?.barButtonItem = sender
        present(activityViewController, animated: true)
    }
}

// MARK: - UICollectionViewDataSource / UICollectionViewDelegate
extension GiphyListViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.numberOfItemsInSection(section)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cellContentType = viewModel.cellContent(for: indexPath)
        
        switch cellContentType {
        case .loading:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "\(LoaderCollectionViewCell.self)", for: indexPath) as! LoaderCollectionViewCell
            cell.backgroundColor = UIColor.appBeige
            cell.activityIndicator.startAnimating()
            return cell
            
        case .giphy(let giphy):
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "\(GiphyCollectionViewCell.self)", for: indexPath) as! GiphyCollectionViewCell
            cell.giphy = giphy
            cell.imageView.backgroundColor = viewModel.colorArt(for: indexPath)?.bestColor ?? .lightGray
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        viewModel.requestNextPageIfNeeded(for: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard case let .giphy(giphy) = viewModel.cellContent(for: indexPath),
              let cell = collectionView.cellForItem(at: indexPath) as? GiphyCollectionViewCell,
              let giphyDetailViewController = viewModel.viewController(for: indexPath) else { return }
        selectedURL = giphy.images[GiphyViewModel.listImageType.rawValue]?.url
        selectedImageView = cell.imageView
        sheetContainerViewController?.present(giphyDetailViewController, animated: true)
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension GiphyListViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return viewModel.sizeForItem(at: indexPath, maxWidth: collectionView.bounds.width, maxHeight: collectionView.bounds.height)
    }
}

// MARK: - UICollectionViewDragDelegate
@available(iOS 11.0, *)
extension GiphyListViewController: UICollectionViewDragDelegate {
    func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        guard let dragItem = dragItem(for: indexPath) else { return [] }
        return [dragItem]
    }
    
    func collectionView(_ collectionView: UICollectionView, itemsForAddingTo session: UIDragSession, at indexPath: IndexPath, point: CGPoint) -> [UIDragItem] {
        guard let dragItem = dragItem(for: indexPath) else { return [] }
        return [dragItem]
    }
    
    private func dragItem(for indexPath: IndexPath) -> UIDragItem? {
        guard let cell = collectionView.cellForItem(at: indexPath) as? GiphyCollectionViewCell,
            let data = cell.imageView?.animatedImage?.data else { return nil }
        let itemProvider = NSItemProvider()
        itemProvider.registerDataRepresentation(forTypeIdentifier: kUTTypeGIF as String, visibility: .all) { completion in
            completion(data, nil)
            return nil
        }
        let dragItem = UIDragItem(itemProvider: itemProvider)
        return dragItem
    }
}

// MARK: - UIScrollViewDelegate
extension GiphyListViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let scrollSpeed = scrollView.contentOffset.y - previousScrollViewYOffset
        previousScrollViewYOffset = scrollView.contentOffset.y
        if scrollSpeed < 0 {
            navigationController?.setNavigationBarHidden(false, animated: true)
        }
        if sheetContainerViewController?.isSheetUp == false {
            sheetContainerViewController?.setSheetHidden(hidden: navigationController?.isNavigationBarHidden == true)
        }
        collectionView.collectionViewLayout.invalidateLayout()
    }
}

// MARK: - MagicMoveFromViewControllerDataSource
extension GiphyListViewController: MagicMoveFromViewControllerDataSource {
    
    var fromMagicView: FLAnimatedImageView? {
        return selectedImageView
    }
    
    var fromURL: URL? {
        return selectedURL
    }
}

// MARK: - GiphyViewModelDelegate
extension GiphyListViewController: GiphyViewModelDelegate, ErrorHandleable {
    
    func giphyViewModel(_ viewModel: GiphyViewModel, didUpdate giphies: [Giphy]) {
        activityIndicator?.stopAnimating()
        refresh.endRefreshing()
        collectionView?.reloadData()
    }
    
    func giphyViewModel(_ viewModel: GiphyViewModel, updateFailedWith error: Error) {
        refresh.endRefreshing()
        handle(error)
    }
    
    func giphyViewModel(_ viewModel: GiphyViewModel, didUpdate colorArt: ColorArt?, for giphy: Giphy) {
        let giphyCells = collectionView.visibleCells.flatMap { $0 as? GiphyCollectionViewCell }
        guard let cell = giphyCells.first(where: { $0.giphy == giphy }) else { return }
        cell.imageView.backgroundColor = colorArt?.bestColor ?? .lightGray
    }
}

// MARK: - SearchViewControllerDelegate
extension GiphyListViewController: SearchViewControllerDelegate {
    
    func searchViewController(_ viewController: SearchViewController, didFinishSearchingWith searchString: String) {
        viewModel = GiphyViewModel(contentType: .search(searchString.capitalized))
        sheetContainerViewController?.animateDown()
    }
}

// MARK: - UIDropInteractionDelegate
@available(iOS 11.0, *)
extension GiphyListViewController: UIDropInteractionDelegate {
        
    func dropInteraction(_ interaction: UIDropInteraction, canHandle session: UIDropSession) -> Bool {
        return session.hasItemsConforming(toTypeIdentifiers: [kUTTypeURL as String])
    }
    
    func dropInteraction(_ interaction: UIDropInteraction, sessionDidUpdate session: UIDropSession) -> UIDropProposal {
        if session.hasItemsConforming(toTypeIdentifiers: [kUTTypeURL as String]) {
            return UIDropProposal(operation: .copy)
        }
        return UIDropProposal(operation: .forbidden)
    }
    
    func dropInteraction(_ interaction: UIDropInteraction, performDrop session: UIDropSession) {
        session.loadObjects(ofClass: NSString.self) { [unowned self] (itemProviders) in
            guard let itemProvider = itemProviders.first as? NSString,
                  let url = URL(string: itemProvider as String),
                  let searchString = self.viewModel.searchString(from: url) else { return }
            self.viewModel = GiphyViewModel(contentType: .search(searchString))
        }
    }
}

// MARK: - UIViewControllerPreviewingDelegate
extension GiphyListViewController: UIViewControllerPreviewingDelegate {
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        
        guard let indexPath = collectionView.indexPathForItem(at: location),
              let giphyListViewController = viewModel.viewController(for: indexPath),
              case let .giphy(giphy) = viewModel.cellContent(for: indexPath),
              let cell = collectionView.cellForItem(at: indexPath) as? GiphyCollectionViewCell else { return nil }
        
        selectedURL = giphy.images[GiphyViewModel.listImageType.rawValue]?.url
        selectedImageView = cell.imageView
        let rect = collectionView.layoutAttributesForItem(at: indexPath)?.frame ?? .zero
        previewingContext.sourceRect = rect
        giphyListViewController.isPeeking = true
        giphyListViewController.preferredContentSize = viewModel.sizeForItem(at: indexPath, maxWidth: sheetContainerViewController?.view.bounds.width ?? 0, maxHeight: sheetContainerViewController?.view.bounds.height ?? 0)
        return giphyListViewController
    }
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        if let giphyDetailViewController = viewControllerToCommit as? GiphyDetailViewController {
            giphyDetailViewController.isPeeking = false
        }
        sheetContainerViewController?.present(viewControllerToCommit, animated: true)
    }
}

