//
//  SearchViewController.swift
//  Giphy Browser
//
//  Created by B Gay on 11/6/17.
//  Copyright © 2017 Brad G. All rights reserved.
//

import UIKit

/// Protocol that informs delegate of important state changes
protocol SearchViewControllerDelegate: class {
    func searchViewController(_ viewController: SearchViewController, didFinishSearchingWith searchString: String)
}

/// A view controller that allows users to enter search terms and displays autocompletion
final class SearchViewController: UIViewController, StoryboardInitializable {
    
    // MARK: - Types
    enum State {
        case searching
        case empty
    }
    
    // MARK: - Outlets
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var emptyStateView: UIView!
    
    // MARK: - Properties
    let searchViewModel = SearchViewModel()
    let searchEmptyStateViewController = SearchEmptyStateViewController()
    weak var delegate: SearchViewControllerDelegate?
    var previewingContext: UIViewControllerPreviewing?
    var state = State.empty {
        didSet {
            updateState()
        }
    }
    
    // MARK: - Lazy Inits
    lazy var searchController: UISearchController = {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.delegate = self
        searchController.searchResultsUpdater = self
        searchController.searchBar.tintColor = .appRed
        searchController.searchBar.delegate = self
        searchController.dimsBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
        self.definesPresentationContext = true
        (UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]) ).defaultTextAttributes = [NSAttributedStringKey.font.rawValue: UIFont.appFont(weight: .medium, pointSize: 20.0)]
        return searchController
    }()
    
    lazy private var tapGesture: UITapGestureRecognizer = {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.didTapNavigationBar(_:)))
        return tapGesture
    }()
    
    lazy private var emptyStateTapGesture: UITapGestureRecognizer = {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.didTapEmptyState(_:)))
        return tapGesture
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        searchViewModel.delegate = self
        setupUI()
    }

    // MARK: - Setup
    private func setupUI() {
        view.backgroundColor = UIColor.appBeige.withAlphaComponent(0.75)
        title = "Search"
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.font: UIFont.appFont(weight: .medium, pointSize: 23.0)]
        
        navigationController?.navigationBar.barTintColor = UIColor.appBeige
        navigationController?.navigationBar.tintColor = UIColor.appRed
        navigationController?.navigationBar.addGestureRecognizer(tapGesture)
        
        if #available(iOS 11.0, *) {
            navigationItem.searchController = searchController
            tableView.dragDelegate = self
            tableView.dragInteractionEnabled = true
        }
        else {
            tableView.tableHeaderView = searchController.searchBar
        }
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.tableFooterView = UIView()
        tableView.panGestureRecognizer.addTarget(self, action: #selector(self.handlePan(_:)))
        tableView.separatorEffect = UIVibrancyEffect(blurEffect: UIBlurEffect(style: .light))
        
        add(childViewController: searchEmptyStateViewController, to: emptyStateView, at: 0)
        searchEmptyStateViewController.view.addGestureRecognizer(emptyStateTapGesture)
        
        if traitCollection.forceTouchCapability == .available {
            registerForPreviewing(with: self, sourceView: tableView)
        }
    }
    
    // MARK: - Helpers
    private func attributedString(for name: String, searchString: String) -> NSAttributedString {
        let attribString = NSMutableAttributedString(string: name.capitalized, attributes: [NSAttributedStringKey.font: UIFont.appFont(textStyle: .headline, weight: .medium)])
        let range = (name.lowercased() as NSString).range(of: searchString.lowercased())
        attribString.addAttribute(.foregroundColor, value: UIColor.appBlue, range: range)
        return attribString
    }
    
    // MARK: - Actions
    @objc private func handlePan(_ sender: UIPanGestureRecognizer) {
        if tableView.contentOffset.y < 0.0 {
            sheetContainerViewController?.handlePan(sender)
        }
    }
    
    @IBAction func didTapEmptyState(_ sender: UITapGestureRecognizer) {
        searchController.isActive = false
    }
    
    @objc func didTapNavigationBar(_ sender: UITapGestureRecognizer) {
        sheetContainerViewController?.animateUp()
    }
    
    // MARK: - Helpers
    private func updateState() {
        let alpha: CGFloat
        switch state {
        case .empty:
            alpha = 1.0
        case .searching:
            alpha = 0.0
        }
        
        UIView.animate(withDuration: 0.2) { [unowned self] in
            self.emptyStateView.alpha = alpha
        }
    }
}

// MARK: - UITableViewDataSource / UITableViewDelegate
extension SearchViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchViewModel.numberOfItemsInSection(section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "\(UITableViewCell.self)", for: indexPath)
        let name = searchViewModel.autocomplete(for: indexPath).name
        cell.textLabel?.attributedText = attributedString(for: name, searchString: searchViewModel.searchString ?? "")
        cell.textLabel?.numberOfLines = 0
        cell.backgroundView?.backgroundColor = UIColor.appBeige.withAlphaComponent(0.5)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let autoComplete = searchViewModel.autocomplete(for: indexPath)
        searchController.isActive = false
        delegate?.searchViewController(self, didFinishSearchingWith: autoComplete.name)
    }
}

// MARK: - SearchViewModelDelegate
extension SearchViewController: SearchViewModelDelegate {
    
    func searchViewModel(_ viewModel: SearchViewModel, didUpdateWith autocompletes: [GiphyAutocomplete], from oldValue: [GiphyAutocomplete]) {
        tableView.animateUpdate(oldDataSource: oldValue, newDataSource: autocompletes)
        state = autocompletes.isEmpty ? .empty : .searching
    }
    
    func searchViewModel(_ viewModel: SearchViewModel, didFailToUpdateWith error: Error) {}
}

// MARK: - UISearchResultsUpdating
extension SearchViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        searchViewModel.searchString = searchController.searchBar.text
    }
}

// MARK: - UISearchBarDelegate
extension SearchViewController: UISearchBarDelegate {
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        sheetContainerViewController?.animateUp()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let searchString = searchBar.text, searchString.isEmpty == false else { return }
        searchController.isActive = false
        delegate?.searchViewController(self, didFinishSearchingWith: searchString)
    }
}

// MARK: - UISearchControllerDelegate
extension SearchViewController: UISearchControllerDelegate {
    func didPresentSearchController(_ searchController: UISearchController) {
        previewingContext = searchController.registerForPreviewing(with: self, sourceView: tableView)
        if #available(iOS 11.0, *) {
            tableView.dragDelegate = self
            tableView.dragInteractionEnabled = true
        }
    }
}

// MARK: - UITableViewDragDelegate
@available(iOS 11.0, *)
extension SearchViewController: UITableViewDragDelegate {
    
    func tableView(_ tableView: UITableView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        let autocomplete = searchViewModel.autocomplete(for: indexPath)
        guard let url = autocomplete.shareURL as NSURL? else { return [] }
        let dragURLItem = UIDragItem(itemProvider: NSItemProvider(object: url))
        return [dragURLItem]
    }
}

// MARK: - UIViewControllerPreviewingDelegate
extension SearchViewController: UIViewControllerPreviewingDelegate {
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        guard let indexPath = tableView.indexPathForRow(at: location) else { return nil }
        let rect = tableView.rectForRow(at: indexPath)
        previewingContext.sourceRect = rect
        let autocomplete = searchViewModel.autocomplete(for: indexPath)
        let giphyViewController = GiphyListViewController.makeFromStoryboard()
        giphyViewController.viewModel = GiphyViewModel(contentType: .search(autocomplete.name))
        let navController = UINavigationController(rootViewController: giphyViewController)
        return navController
    }
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        guard let navController = viewControllerToCommit as? UINavigationController,
              let giphyViewController = navController.viewControllers.first as? GiphyListViewController else { return }
        searchController.searchBar.text = nil
        delegate = giphyViewController
        sheetContainerViewController?.masterViewController = navController
        sheetContainerViewController?.animateDown()
    }
}
