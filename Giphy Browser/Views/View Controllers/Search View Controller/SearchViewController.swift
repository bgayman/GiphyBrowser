//
//  SearchViewController.swift
//  Giphy Browser
//
//  Created by B Gay on 11/6/17.
//  Copyright © 2017 Brad G. All rights reserved.
//

import UIKit
import CoreMotion

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
    @IBOutlet private var mainEmptyStateView: MagnifyingGlassView!
    @IBOutlet private var emptyStateLabel: UILabel!
    
    // MARK: - Properties
    let searchViewModel = SearchViewModel()
    weak var delegate: SearchViewControllerDelegate?
    let motionManager = CMMotionManager()
    var previewingContext: UIViewControllerPreviewing?
    var state = State.empty {
        didSet {
            updateState()
        }
    }
    
    // MARK: - Lazy Inits
    lazy private var dynamicAnimator: UIDynamicAnimator = {
        let dynamicAnimator = UIDynamicAnimator(referenceView: self.emptyStateView)
        return dynamicAnimator
    }()
    
    lazy private var gravity: UIGravityBehavior = {
        let gravity = UIGravityBehavior(items: dynamicItems)
        gravity.magnitude = 0.5
        return gravity
    }()
    
    lazy private var collision: UICollisionBehavior = {
        let inset = UIEdgeInsets(top: 0, left: 0, bottom: (self.sheetContainerViewController?.topOffset ?? 0), right: 0)
        let collision = UICollisionBehavior(items: dynamicItems)
        collision.setTranslatesReferenceBoundsIntoBoundary(with: inset)
        return collision
    }()
    
    lazy private var mainAttachmentBehavior: UIAttachmentBehavior = {
        let mainAttachmentBehavior = UIAttachmentBehavior(item: self.mainEmptyStateView, attachedToAnchor: CGPoint(x: self.emptyStateView.center.x, y: self.emptyStateView.center.y - (self.sheetContainerViewController?.topOffset ?? 0.0) - 20.0))
        mainAttachmentBehavior.length = 0.0
        return mainAttachmentBehavior
    }()
    
    lazy private var labelAttachmentBehavior: UIAttachmentBehavior = {
        let labelAttachmentBehavior = UIAttachmentBehavior.limitAttachment(with: self.mainEmptyStateView, offsetFromCenter: .zero, attachedTo: self.emptyStateLabel, offsetFromCenter: .zero)
        labelAttachmentBehavior.length = self.mainEmptyStateView.bounds.midY + self.emptyStateLabel.bounds.midY + 15.0
        labelAttachmentBehavior.damping = 1.0
        return labelAttachmentBehavior
    }()
    
    lazy private var itemBehavior: UIDynamicItemBehavior = {
        let itemBehavior = UIDynamicItemBehavior(items: [self.mainEmptyStateView, self.emptyStateLabel])
        itemBehavior.allowsRotation = false
        itemBehavior.angularResistance = 6.0
        itemBehavior.resistance = 2.0
        itemBehavior.density = 2.0
        return itemBehavior
    }()
    
    lazy private var magnifyingGlassItemBehavior: UIDynamicItemBehavior = {
        let items: [UIDynamicItem] = self.magnifyingGlassViews as [UIDynamicItem] + self.giphyViews as [UIDynamicItem]
        let itemBehavior = UIDynamicItemBehavior(items: items)
        itemBehavior.allowsRotation = true
        itemBehavior.elasticity = 0.4
        itemBehavior.angularResistance = 5
        return itemBehavior
    }()
    
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
    
    lazy var magnifyingGlassViews: [MagnifyingGlassView] = {
        var magnifyingGlassViews = [MagnifyingGlassView]()
        for _ in 0 ..< 200 {
            let magnifyingGlassView = MagnifyingGlassView(frame: .zero)
            self.emptyStateView.addSubview(magnifyingGlassView)
            magnifyingGlassViews.append(magnifyingGlassView)
        }
        return magnifyingGlassViews
    }()
    
    lazy var giphyViews: [GiphyView] = {
        var giphyViews = [GiphyView]()
        for _ in 0 ..< 20 {
            let giphyView = GiphyView(frame: .zero)
            self.emptyStateView.addSubview(giphyView)
            giphyViews.append(giphyView)
        }
        return giphyViews
    }()
    
    // MARK: - Computed Properties
    var dynamicItems: [UIDynamicItem] {
        return magnifyingGlassViews as [UIDynamicItem] + [mainEmptyStateView, emptyStateLabel] as [UIDynamicItem] + giphyViews as [UIDynamicItem]
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        searchViewModel.delegate = self
        setupUI()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        mainEmptyStateView.frame = CGRect(x: emptyStateView.center.x, y: emptyStateView.center.y - (sheetContainerViewController?.topOffset ?? 0), width: min(425, emptyStateView.bounds.width - 100), height: min(425, emptyStateView.bounds.width - 100))
        dynamicAnimator.updateItem(usingCurrentState: mainEmptyStateView)
        mainAttachmentBehavior.anchorPoint = CGPoint(x: emptyStateView.center.x, y: emptyStateView.center.y - (sheetContainerViewController?.topOffset ?? 0) - 100.0)
        arrange(giphyViews)
        arrange(magnifyingGlassViews)
    }

    // MARK: - Setup
    private func setupUI() {
        view.backgroundColor = UIColor.appBeige.withAlphaComponent(0.75)
        title = "Search"
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.font: UIFont.appFont(weight: .medium, pointSize: 23.0)]
        
        navigationController?.navigationBar.barTintColor = UIColor.appBeige
        navigationController?.navigationBar.tintColor = UIColor.appRed
        
        if #available(iOS 11.0, *) {
            navigationItem.searchController = searchController
        }
        else {
            tableView.tableHeaderView = searchController.searchBar
        }
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.tableFooterView = UIView()
        tableView.panGestureRecognizer.addTarget(self, action: #selector(self.handlePan(_:)))
        tableView.separatorEffect = UIVibrancyEffect(blurEffect: UIBlurEffect(style: .light))
        
        mainEmptyStateView.translatesAutoresizingMaskIntoConstraints = true
        emptyStateView.addSubview(mainEmptyStateView)
        emptyStateLabel.font = UIFont.appFont(textStyle: .title2, weight: .medium)
        emptyStateLabel.textColor = .lightGray
        emptyStateLabel.numberOfLines = 0
        emptyStateLabel.translatesAutoresizingMaskIntoConstraints = true
        emptyStateLabel.center = CGPoint(x: emptyStateView.bounds.midX, y: emptyStateView.bounds.maxY - 100.0)
        emptyStateView.addSubview(emptyStateLabel)
        
        arrange(giphyViews)
        arrange(magnifyingGlassViews)
        
        dynamicAnimator.addBehavior(gravity)
        dynamicAnimator.addBehavior(collision)
        dynamicAnimator.addBehavior(mainAttachmentBehavior)
        dynamicAnimator.addBehavior(labelAttachmentBehavior)
        dynamicAnimator.addBehavior(itemBehavior)
        dynamicAnimator.addBehavior(magnifyingGlassItemBehavior)
        motionManager.startDeviceMotionUpdates(to: OperationQueue.main, withHandler: gravityUpdated)
        
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
    
    private func arrange(_ views: [UIView]) {
        views.forEach {
            let size: CGFloat = CGFloat(arc4random() % 30 + 20)
            let x: CGFloat = CGFloat(arc4random() % UInt32(self.emptyStateView.bounds.width - 100) + 50)
            let y: CGFloat = CGFloat(arc4random() % UInt32(self.emptyStateView.bounds.height - 200) + 400)
            $0.frame = CGRect(x: x, y: y, width: size, height: size)
            self.dynamicAnimator.updateItem(usingCurrentState: $0)
        }
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
    // MARK: - Core Motion
    @objc
    private func gravityUpdated(motion: CMDeviceMotion?, error: Error?) {
        
        guard let motion = motion else { return }
        let grav: CMAcceleration = motion.gravity;
        
        let x = CGFloat(grav.x)
        let y = CGFloat(grav.y)
        var p = CGPoint(x: x, y: y)
        
        let orientation = UIApplication.shared.statusBarOrientation;
        
        if orientation == UIInterfaceOrientation.landscapeRight {
            let t = p.x
            p.x = 0 - p.y
            p.y = t
        }
        else if orientation == UIInterfaceOrientation.landscapeLeft {
            let t = p.x
            p.x = p.y
            p.y = 0 - t
        }
        else if orientation == UIInterfaceOrientation.portraitUpsideDown {
            p.x = p.x * -1
            p.y = p.y * -1
        }
        
        let v = CGVector(dx: p.x, dy: 0 - p.y)
        gravity.gravityDirection = v
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

extension SearchViewController: UISearchControllerDelegate {
    func didPresentSearchController(_ searchController: UISearchController) {
        previewingContext = searchController.registerForPreviewing(with: self, sourceView: tableView)
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
