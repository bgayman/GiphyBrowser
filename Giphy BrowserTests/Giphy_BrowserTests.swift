//
//  Giphy_BrowserTests.swift
//  Giphy BrowserTests
//
//  Created by Brad G. on 11/4/17.
//  Copyright © 2017 Brad G. All rights reserved.
//

import XCTest
@testable import Giphy_Browser

class Giphy_BrowserTests: XCTestCase {
    var giphyResponse: GiphyResponse?
    var giphyAutocompleteResponse: GiphyAutocompleteResponse?
    var viewModel = GiphyViewModel(contentType: .search("ryan gosling"))
    
    override func setUp() {
        super.setUp()
        giphyResponse = GiphySearchClient.loadTestData()
        giphyAutocompleteResponse = GiphyAutocompleteClient.loadTestData()
        if let response = giphyResponse {
            viewModel.supplyTestData(response: response)
        }
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testGiphyResponseParsing() {
        XCTAssertNotNil(giphyResponse, "`giphyResponse` must not be nil.")
        XCTAssertEqual(giphyResponse?.giphies.count, 5, "`giphyResponse.giphies.count` must be 5.")
        XCTAssertEqual(giphyResponse?.giphies.first?.images.keys.count, 23, "`giphyResponse?.giphies.first?.images.keys.count` must equal 23")
    }
    
    func testGiphyAutocompleteParsing() {
        XCTAssertNotNil(giphyAutocompleteResponse, "`giphyAutocompleteResponse` must not be nil.")
        XCTAssertEqual(giphyAutocompleteResponse?.result.results.count, 8, "`giphyAutocompleteResponse?.result.results.count` must be equal to 8")
    }
    
    func testLoadingGiphySearchResponseFromServer() {
        let serverExpectation = expectation(description: "Loading from server.")
        GiphySearchClient.getSearchResult(for: "lions") { (result) in
            switch result {
            case .error(let error):
                XCTFail("Loading search results from server must not result in error. Error: \(error.localizedDescription)")
            case .success:
                serverExpectation.fulfill()
            }
        }
        
        waitForExpectations(timeout: 30.0) { (error) in
            print(error?.localizedDescription ?? "")
        }
    }
    
    func testLoadingGiphyTrendingResponseFromServer() {
        let serverExpectation = expectation(description: "Loading from server.")
        GiphyTrendingClient.getTrending { (result) in
            switch result {
            case .error(let error):
                XCTFail("Loading trending from server must not result in error. Error: \(error.localizedDescription)")
            case .success:
                serverExpectation.fulfill()
            }
        }
        waitForExpectations(timeout: 30.0) { (error) in
            print(error?.localizedDescription ?? "")
        }
    }
    
    func testLoadingGiphyAutocompletionResponseFromServer() {
        let serverExpectation = expectation(description: "Loading from server.")
        GiphyAutocompleteClient.getAutocompletions(for: "ca") { (result) in
            switch result {
            case .error(let error):
                XCTFail("Loading autocompletions from server must not result in error. Error: \(error.localizedDescription)")
            case .success:
                serverExpectation.fulfill()
            }
        }
        waitForExpectations(timeout: 30.0) { (error) in
            print(error?.localizedDescription ?? "")
        }
    }
    
    func testViewModel() {
        
        XCTAssertNotNil(viewModel, "`viewModel` must not be nil.")
        
        XCTAssertEqual(viewModel.giphies.count, 5, "`viewModel.giphies.count` must be 5.")
        XCTAssertEqual(viewModel.numberOfItemsInSection(0), 6, "`viewModel.numberOfItemsInSection(0)` count must be 6")
        
        XCTAssertEqual(viewModel.title, "Ryan Gosling", "`viewModel.title` must be 'Ryan Gosling'.")
        XCTAssertEqual(viewModel.contentType, GiphyViewModel.ContentType.search("Ryan Gosling"), "`viewModel.contentType` must be `.search('Ryan Gosling')`.")
        
        let lastIndexPath = IndexPath(item: 5, section: 0)
        let lastCellContent = viewModel.cellContent(for: lastIndexPath)
        XCTAssertEqual(lastCellContent, .loading, "Last cell must be of type `.loading`")
        
        let firstIndexPath = IndexPath(item: 0, section: 0)
        let firstCellContent = viewModel.cellContent(for: firstIndexPath)
        XCTAssertEqual(firstCellContent, .giphy(giphyResponse!.giphies.first!), "Last cell must be of type `.giphy`")
        
        let firstSize = viewModel.sizeForItem(at: firstIndexPath, maxWidth: 320.0, maxHeight: 520.0)
        XCTAssertEqual(firstSize, CGSize(width: 322, height: 200), "First size must be 322 x 200")
        
        let lastSize = viewModel.sizeForItem(at: lastIndexPath, maxWidth: 320.0, maxHeight: 520.0)
        XCTAssertEqual(lastSize, CGSize(width: 320.0, height: 44), "Last size must be 320 x 44")
    }
}
