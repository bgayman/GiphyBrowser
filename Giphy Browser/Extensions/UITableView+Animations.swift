//
//  UITableView+Animations.swift
//  Giphy Browser
//
//  Created by B Gay on 11/6/17.
//  Copyright © 2017 Brad G. All rights reserved.
//

import UIKit

/// Adds animated updating
extension UITableView {
    
    func animateUpdate<T: Hashable>(oldDataSource: [T], newDataSource: [T]) {
        let oldArray = oldDataSource
        let oldSet = Set(oldArray)
        let newArray = newDataSource
        let newSet = Set(newArray)
        
        let removed = oldSet.subtracting(newSet)
        let inserted = newSet.subtracting(oldSet)
        let updated = newSet.intersection(oldSet)
        
        let removedIndexes = removed.flatMap{ oldArray.index(of: $0) }.map{ IndexPath(row: $0, section: 0) }
        let insertedIndexes = inserted.flatMap{ newArray.index(of: $0) }.map{ IndexPath(row: $0, section: 0) }
        let updatedIndexes = updated.flatMap{ oldArray.index(of: $0) }.map{ IndexPath(row: $0, section: 0) }
        
        self.beginUpdates()
        self.reloadRows(at: updatedIndexes, with: .automatic)
        self.deleteRows(at: removedIndexes, with: .automatic)
        self.insertRows(at: insertedIndexes, with: .automatic)
        self.endUpdates()
    }
    
    func animateSectionUpdate<T: Hashable>(oldDataSource: [T], newDataSource: [T]) {
        let oldArray = oldDataSource
        let oldSet = Set(oldArray)
        let newArray = newDataSource
        let newSet = Set(newArray)
        
        let removed = oldSet.subtracting(newSet)
        let inserted = newSet.subtracting(oldSet)
        let updated = newSet.intersection(oldSet)
        
        let removedIndexes = IndexSet(removed.flatMap{ oldArray.index(of: $0) })
        let insertedIndexes  = IndexSet(inserted.flatMap{ newArray.index(of: $0) })
        let updatedIndexes = IndexSet(updated.flatMap{ oldArray.index(of: $0) })
        
        self.beginUpdates()
        self.reloadSections(updatedIndexes, with: .none)
        self.deleteSections(removedIndexes, with: .top)
        self.insertSections(insertedIndexes, with: .top)
        self.endUpdates()
    }
}
