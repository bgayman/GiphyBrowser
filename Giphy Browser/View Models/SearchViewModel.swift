//
//  SearchViewModel.swift
//  Giphy Browser
//
//  Created by B Gay on 11/6/17.
//  Copyright © 2017 Brad G. All rights reserved.
//

import Foundation

protocol SearchViewModelDelegate: class {
    func searchViewModel(_ viewModel: SearchViewModel, didUpdateWith autocompletes: [GiphyAutocomplete], from oldValue: [GiphyAutocomplete])
    func searchViewModel(_ viewModel: SearchViewModel, didFailToUpdateWith error: Error)
}

final class SearchViewModel: NSObject {
    
    // MARK: - Properties
    let title = "Search"
    var searchString: String? {
        didSet {
            fetchAutocompletes(for: searchString)
        }
    }
    weak var delegate: SearchViewModelDelegate?
    var autocompletes = [GiphyAutocomplete]() {
        didSet {
            delegate?.searchViewModel(self, didUpdateWith: autocompletes, from: oldValue)
        }
    }
    
    // MARK: - Networking
    private func fetchAutocompletes(for searchString: String?) {
        
        guard let searchString = searchString, searchString.isEmpty == false  else {
            autocompletes = []
            return
        }
        
        GiphyAutocompleteClient.getAutocompletions(for: searchString) { (result) in
            switch result {
            case .error(let error):
                self.delegate?.searchViewModel(self, didFailToUpdateWith: error)
            case .success(let response):
                self.autocompletes = response.result.results
            }
        }
    }
    
    // MARK: - List Handlers
    func numberOfSections() -> Int {
        return 1
    }
    
    func numberOfItemsInSection(_ section: Int) -> Int {
        assert(section == 0, "View model only implementation assumes 1 section")
        return autocompletes.count
    }
    
    func autocomplete(for indexPath: IndexPath) -> GiphyAutocomplete {
        return autocompletes[indexPath.row]
    }
}

