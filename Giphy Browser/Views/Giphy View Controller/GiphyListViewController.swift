//
//  GiphyListViewController.swift
//  Giphy Browser
//
//  Created by Brad G. on 11/4/17.
//  Copyright © 2017 Brad G. All rights reserved.
//

import UIKit
import SDWebImage

/// A view controller that displays GIFs in a scrolling list
final class GiphyListViewController: UIViewController, StoryboardInitializable {
    
    // MARK: - Outlets
    @IBOutlet private weak var collectionView: UICollectionView!
    @IBOutlet private weak var statusBarOverlayView: UIView!
    
    // MARK: - Properties
    private var previousScrollViewYOffset: CGFloat = 0.0
    var viewModel = GiphyViewModel(contentType: .trending) {
        willSet {
            collectionView.animateRemovalOfAllItems(sectionItems: [(0, viewModel.numberOfItemsInSection(0))])
        }
        
        didSet {
            viewModel.delegate = self
            refresh.beginRefreshing()
        }
    }
    
    lazy var refresh: UIRefreshControl = {
       let refresh = UIRefreshControl()
        refresh.addTarget(self, action: #selector(self.refresh(_:)), for: .valueChanged)
        return refresh
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.viewModel.delegate = self
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
            navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedStringKey.font: UIFont.appFont(weight: .heavy, pointSize: 35.0)]
        }
        else {
            navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.font: UIFont.appFont(weight: .medium, pointSize: 23.0)]
        }
        
        navigationController?.hidesBarsOnSwipe = true
        navigationController?.navigationBar.barTintColor = UIColor.appBeige
        navigationController?.navigationBar.tintColor = UIColor.appRed
        
        if #available(iOS 10.0, *) {
            collectionView.refreshControl = refresh
            refresh.beginRefreshing()
        } else {
            collectionView.addSubview(refresh)
        }
    }
    
    // MARK: - Actions
    @objc func refresh(_ sender: UIRefreshControl) {
        viewModel.refresh()
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
            cell.backgroundColor = viewModel.colorArt(for: indexPath)?.bestColor
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        viewModel.requestNextPageIfNeeded(for: indexPath)
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension GiphyListViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return viewModel.sizeForItem(at: indexPath, maxWidth: collectionView.bounds.width, maxHeight: collectionView.bounds.height)
    }
}

// MARK: - UIScrollViewDelegate
extension GiphyListViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let scrollSpeed = scrollView.contentOffset.y - previousScrollViewYOffset
        previousScrollViewYOffset = scrollView.contentOffset.y
        if scrollSpeed < 0 {
            self.navigationController?.setNavigationBarHidden(false, animated: true)
        }
    }
}

// MARK: - GiphyViewModelDelegate
extension GiphyListViewController: GiphyViewModelDelegate, ErrorHandleable {
    
    func giphyViewModel(_ viewModel: GiphyViewModel, didUpdate giphies: [Giphy]) {
        refresh.endRefreshing()
        if collectionView.numberOfItems(inSection: 0) == 0 {
            collectionView.animateInitialLoad(sectionItems: [(0, viewModel.numberOfItemsInSection(0))])
        }
        else {
            collectionView.reloadData()
        }
    }
    
    func giphyViewModel(_ viewModel: GiphyViewModel, updateFailedWith error: Error) {
        refresh.endRefreshing()
        handle(error)
    }
    
    func giphyViewModel(_ viewModel: GiphyViewModel, didUpdate colorArt: ColorArt?, for giphy: Giphy) {
        let giphyCells = collectionView.visibleCells.flatMap { $0 as? GiphyCollectionViewCell }
        guard let cell = giphyCells.first(where: { $0.giphy == giphy }) else { return }
        cell.imageView.backgroundColor = colorArt?.bestColor
    }
}

extension GiphyListViewController: SearchViewControllerDelegate {
    
    func searchViewController(_ viewController: SearchViewController, didFinishSearchingWith searchString: String) {
        viewModel = GiphyViewModel(contentType: .search(searchString))
        sheetContainerViewController?.animateDown()
    }
    
    
}

