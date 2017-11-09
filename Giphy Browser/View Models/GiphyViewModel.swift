//
//  GiphyViewModel.swift
//  Giphy Browser
//
//  Created by Brad G. on 11/5/17.
//  Copyright © 2017 Brad G. All rights reserved.
//

import Foundation
import CoreGraphics
import SDWebImage
import AVFoundation

/// Protocol that informs delegate of changes in view model state
protocol GiphyViewModelDelegate: class {
    func giphyViewModel(_ viewModel: GiphyViewModel, didUpdate giphies: [Giphy])
    func giphyViewModel(_ viewModel: GiphyViewModel, didUpdate colorArt: ColorArt?, for giphy: Giphy)
    func giphyViewModel(_ viewModel: GiphyViewModel, updateFailedWith error: Error)
}

/// View model that handles logic of fetching and displaying a collection of GIFs
final class GiphyViewModel: NSObject {
    
    // MARK: - Types
    enum ContentType {
        case trending
        case search(String)
        
        var title: String {
            switch self {
            case .trending:
                return "Trending"
            case .search(let search):
                return search.capitalized
            }
        }
    }
    
    enum CellContentType {
        case loading
        case giphy(Giphy)
    }
    
    // MARK: - Properties
    static let listImageType = GiphyImageType.fixedWidthDownsampled
    static let stillPreviewType = GiphyImageType.fixedWidthSmallStill
    
    let contentType: ContentType
    weak var delegate: GiphyViewModelDelegate?
    
    // MARK: - Private Properties
    private var currentOffset = 0
    private var shouldShowBottomLoadingCell = false
    private var colors = [URL: ColorArt]()
    private (set) var giphies = [Giphy]() {
        didSet {
            self.delegate?.giphyViewModel(self, didUpdate: giphies)
        }
    }

    // MARK: - Computed Properties
    var title: String {
        return contentType.title
    }
    
    var shareURL: URL? {
        switch contentType {
        case .trending:
            return URL(string: "https://giphy.com")
        case .search(let searchString):
            let encodedSearchString = searchString.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlPathAllowed)
            return URL(string: "https://giphy.com/search/\(encodedSearchString ?? "")")
        }
    }
    
    // MARK: - Lifecycle
    init(contentType: GiphyViewModel.ContentType) {
        self.contentType = contentType
        super.init()
        fetchGiphies()
    }
    
    // MARK: - Networking
    func fetchGiphies(refresh: Bool = false) {
        switch contentType {
        case .trending:
            fetchTrending(refresh: refresh)
        case .search(let search):
            fetchSearch(search: search, refresh: refresh)
        }
    }
    
    private func fetchTrending(refresh: Bool) {
        GiphyTrendingClient.getTrending(offset: currentOffset) {
            self.process($0, refresh: refresh)
        }
    }
    
    private func fetchSearch(search: String, refresh: Bool) {
        GiphySearchClient.getSearchResult(for: search, offset: currentOffset) {
            self.process($0, refresh: refresh)
        }
    }
    
    private func process(_ result: Result<GiphyResponse>, refresh: Bool) {
        switch result {
        case .error(let error):
            self.delegate?.giphyViewModel(self, updateFailedWith: error)
        case .success(let response):
            self.shouldShowBottomLoadingCell = response.giphies.isEmpty == false
            self.processStillImageColors(response: response)
            if refresh {
                self.giphies = response.giphies
            }
            else {
                let notIncludedGiphies = response.giphies.filter { !self.giphies.contains($0) }
                self.giphies.append(contentsOf: notIncludedGiphies)
            }
        }
    }
    
    private func fetchNextPage() {
        currentOffset += giphies.count
        fetchGiphies()
    }
    
    func refresh() {
        currentOffset = 0
        fetchGiphies(refresh: true)
    }
    
    // MARK: - List Handlers
    func numberOfSections() -> Int {
        return 1
    }
    
    func numberOfItemsInSection(_ section: Int) -> Int {
        assert(section == 0, "View model only implementation assumes 1 section")
        return shouldShowBottomLoadingCell ? giphies.count + 1 : giphies.count
    }
    
    func cellContent(for indexPath: IndexPath) -> GiphyViewModel.CellContentType {
        if isLoadingIndexPath(indexPath) {
            return .loading
        }
        let giphy = giphies[indexPath.item]
        return .giphy(giphy)
    }
    
    func requestNextPageIfNeeded(for indexPath: IndexPath) {
        guard isLoadingIndexPath(indexPath) else { return }
        fetchNextPage()
    }
    
    func colorArt(for indexPath: IndexPath) -> ColorArt? {
        let giphy = giphies[indexPath.row]
        guard let url = giphy.images[GiphyViewModel.stillPreviewType.rawValue]?.url else { return nil }
        return colors[url]
    }
    
    func sizeForItem(at indexPath: IndexPath, maxWidth: CGFloat, maxHeight: CGFloat) -> CGSize {
        if isLoadingIndexPath(indexPath) {
            return CGSize(width: maxWidth, height: 44.0)
        }
        let image = giphies[indexPath.item].images[GiphyViewModel.listImageType.rawValue]
        let width = CGFloat(image?.width ?? 0)
        let height = CGFloat(image?.height ?? 0)
        let size = CGSize(width: width, height: height)
        let maxSize = CGSize(width: min(425, maxWidth), height: min(700, maxHeight))
        let rect = AVMakeRect(aspectRatio: size, insideRect: CGRect(origin: .zero, size: maxSize))
        return rect.size
    }
    
    func viewController(for indexPath: IndexPath) -> GiphyDetailViewController? {
        guard isLoadingIndexPath(indexPath) == false else { return nil }
        let giphy = giphies[indexPath.item]
        let colorArt = self.colorArt(for: indexPath)
        let giphyDetailViewController = GiphyDetailViewController(giphy: giphy, colorArt: colorArt)
        giphyDetailViewController.modalPresentationCapturesStatusBarAppearance = true
        giphyDetailViewController.modalPresentationStyle = .custom
        giphyDetailViewController.transitioningDelegate = giphyDetailViewController
        return giphyDetailViewController
    }
    
    // MARK: - Helpers
    private func isLoadingIndexPath(_ indexPath: IndexPath) -> Bool {
        guard shouldShowBottomLoadingCell else { return  false }
        return indexPath.item == giphies.count
    }
    
    private func processStillImageColors(response: GiphyResponse) {
        let urls = response.giphies.flatMap { $0.images[GiphyViewModel.stillPreviewType.rawValue]?.url }
        urls.forEach {
            SDWebImageManager.shared().loadImage(with: $0, options: [], progress: nil)
            { (image, _, _, _, _, url) in
                guard let image = image, let url = url  else { return }
                ColorArt.processImage(image, scaledToSize: image.size, withThreshold: 8) { (colorArt) in
                    self.colors[url] = colorArt
                    guard let giphy = response.giphies.first(where: { $0.images[GiphyViewModel.stillPreviewType.rawValue]?.url == url }) else { return }
                    self.delegate?.giphyViewModel(self, didUpdate: colorArt, for: giphy)
                }
            }
        }
    }
    
    func searchString(from url: URL?) -> String? {
        guard url?.host == "giphy.com",
              url?.pathComponents.contains("search") == true,
              let searchString = url?.pathComponents.last?.removingPercentEncoding else { return nil }
        return searchString
    }
    
    // MARK: - Test Helpers
    func supplyTestData(response: GiphyResponse) {
        giphies = response.giphies
        shouldShowBottomLoadingCell = !giphies.isEmpty
    }
}

// MARK: - GiphyViewModel.ContentType + Equatable
extension GiphyViewModel.ContentType: Equatable {
    static func == (lhs: GiphyViewModel.ContentType, rhs: GiphyViewModel.ContentType) -> Bool {
        switch (lhs, rhs) {
        case let (.search(lhsSearch), .search(rhsSearch)):
            return lhsSearch.lowercased() == rhsSearch.lowercased()
        case (.trending, .trending):
            return true
        default:
            return false
        }
    }
}

// MARK: - GiphyViewModel.CellContentType + Equatable
extension GiphyViewModel.CellContentType: Equatable {
    static func == (lhs: GiphyViewModel.CellContentType, rhs: GiphyViewModel.CellContentType) -> Bool {
        switch (lhs, rhs) {
        case let (.giphy(lhsGiphy), .giphy(rhsGiphy)):
            return lhsGiphy == rhsGiphy
        case (.loading, .loading):
            return true
        default:
            return false
        }
    }
}

// MARK: - GiphyViewModel.CellContentType + Hashable
extension GiphyViewModel.CellContentType: Hashable {
    var hashValue: Int {
        switch self {
        case .loading:
            return "loading cell".hashValue
        case .giphy(let giphy):
            return giphy.id.hashValue
        }
    }
}
