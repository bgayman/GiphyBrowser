//
//  GiphyListViewController.swift
//  Giphy Browser
//
//  Created by Brad G. on 11/4/17.
//  Copyright © 2017 Brad G. All rights reserved.
//

import UIKit
import SDWebImage

class GiphyListViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet private weak var collectionView: UICollectionView!
    
    // MARK: - Properties
    var viewModel = GiphyViewModel(contentType: .search("Lion"))
    
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
    
    // MARK: - Setup
    private func setupUI() {
        view.backgroundColor = UIColor.appBeige
        collectionView.refreshControl = refresh
        collectionView.refreshControl?.beginRefreshing()
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

// MARK: - GiphyViewModelDelegate
extension GiphyListViewController: GiphyViewModelDelegate {
    
    func giphyViewModel(_ viewModel: GiphyViewModel, didUpdate giphies: [Giphy]) {
        collectionView.refreshControl?.endRefreshing()
        collectionView.reloadData()
    }
    
    func giphyViewModel(_ viewModel: GiphyViewModel, updateFailedWith error: Error) {
        collectionView.refreshControl?.endRefreshing()
    }
}

