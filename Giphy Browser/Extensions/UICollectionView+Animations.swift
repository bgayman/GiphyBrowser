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
    
}
