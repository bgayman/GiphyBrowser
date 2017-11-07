//
//  SearchViewController.swift
//  Giphy Browser
//
//  Created by B Gay on 11/6/17.
//  Copyright © 2017 Brad G. All rights reserved.
//

import UIKit

protocol SearchViewControllerDelegate: class {
    func searchViewController(_ viewController: SearchViewController, didFinishSearchingWith searchString: String)
}

final class SearchViewController: UIViewController, StoryboardInitializable {
    
    // MARK: - Outlets
    @IBOutlet private weak var tableView: UITableView!
    
    // MARK: - Properties
    let searchViewModel = SearchViewModel()
    weak var delegate: SearchViewControllerDelegate?
    
    lazy var searchController: UISearchController = {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.searchBar.tintColor = .appRed
        searchController.dimsBackgroundDuringPresentation = true
        searchController.hidesNavigationBarDuringPresentation = false
        (UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]) ).defaultTextAttributes = [NSAttributedStringKey.font.rawValue: UIFont.appFont(weight: .medium, pointSize: 20.0)]
        return searchController
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
        
    }
}

// MARK: - UITableViewDataSource / UITableViewDelegate
extension SearchViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchViewModel.numberOfItemsInSection(section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "\(UITableViewCell.self)", for: indexPath)
        cell.textLabel?.text = searchViewModel.autocomplete(for: indexPath).name
        cell.textLabel?.font = UIFont.appFont(textStyle: .callout, weight: .regular)
        cell.textLabel?.numberOfLines = 0
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let autoComplete = searchViewModel.autocomplete(for: indexPath)
        delegate?.searchViewController(self, didFinishSearchingWith: autoComplete.name)
    }
}

// MARK: - SearchViewModelDelegate
extension SearchViewController: SearchViewModelDelegate {
    
    func searchViewModel(_ viewModel: SearchViewModel, didUpdateWith autocompletes: [GiphyAutocomplete], from oldValue: [GiphyAutocomplete]) {
        tableView.animateUpdate(oldDataSource: oldValue, newDataSource: autocompletes)
    }
    
    func searchViewModel(_ viewModel: SearchViewModel, didFailToUpdateWith error: Error) {}
}

// MARK: - UISearchResultsUpdating
extension SearchViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        searchViewModel.searchString = searchController.searchBar.text
    }
}

extension SearchViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let searchString = searchBar.text, searchString.isEmpty == false else { return }
        delegate?.searchViewController(self, didFinishSearchingWith: searchString)
    }
}
