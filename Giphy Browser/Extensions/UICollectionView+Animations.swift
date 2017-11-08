//
//  UICollectionView+Animations.swift
//  Giphy Browser
//
//  Created by Brad G. on 11/5/17.
//  Copyright © 2017 Brad G. All rights reserved.
//

import UIKit

extension UICollectionView {
    
    func animateUpdate<T: Hashable>(oldDataSource: [T], newDataSource: [T]) {
        let oldArray = oldDataSource
        let oldSet = Set(oldArray)
        let newArray = newDataSource
        let newSet = Set(newArray)
        
        let removed = oldSet.subtracting(newSet)
        let inserted = newSet.subtracting(oldSet)
        let updated = newSet.intersection(oldSet)
        
        let removedIndexes = removed.flatMap{ oldArray.index(of: $0) }.map{ IndexPath(item: $0, section: 0) }
        let insertedIndexes = inserted.flatMap{ newArray.index(of: $0) }.map{ IndexPath(item: $0, section: 0) }
        let updatedIndexes = updated.flatMap{ oldArray.index(of: $0) }.map{ IndexPath(item: $0, section: 0) }
        
        self.performBatchUpdates({
            self.reloadItems(at: updatedIndexes)
            self.deleteItems(at: removedIndexes)
            self.insertItems(at: insertedIndexes)
        })
    }
    
    public func animateInitialPopulation(sectionItems: [(section: Int, itemCount: Int)]) {
        let insertIndexes = self.indexPaths(for: sectionItems)
        self.insertItems(at: insertIndexes)
    }
    
    func animateRemovalOfAllItems(sectionItems: [(section: Int, itemCount: Int)]) {
        let deleteIndexes = self.indexPaths(for: sectionItems)
        self.deleteItems(at: deleteIndexes)
    }
    
    private func indexPaths(for sectionItems: [(section: Int, itemCount: Int)]) -> [IndexPath] {
        var insertIndexes = [IndexPath]()
        for sectionItem in sectionItems {
            for i in 0 ..< sectionItem.1 {
                insertIndexes.append(IndexPath(item: i, section: sectionItem.0))
            }
        }
        return insertIndexes
    }
    
}
