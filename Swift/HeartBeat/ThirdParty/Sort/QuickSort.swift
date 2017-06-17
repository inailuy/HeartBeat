//
//  QuickSort.swift
//  HeartBeat
//
//  Created by inailuy on 8/4/16.
//  Copyright © 2016 Mxtapes. All rights reserved.
//

import Foundation

class QuickSort {
    class func sort(_ arr:inout NSMutableArray, left:Int, right:Int) {
        if left < right {
            let p = partition(&arr, left: left, right: right)
            sort(&arr, left: left, right: p-1)
            sort(&arr, left: p+1, right: right)
        }
    }
    
    class func swap(_ arr:inout NSMutableArray, a:Int, b:Int) {
        let temp = arr[a]
        arr[a] = arr[b]
        arr[b] = temp
    }
    
    class func partition(_ arr:inout NSMutableArray, left:Int, right:Int) -> Int {
        let partition = arr[right].int32Value
        var sortedIndex = left
        
        for i in left..<right {
            if arr[i].int32Value < partition {
                swap(&arr, a: i, b: sortedIndex)
                sortedIndex += 1
            }
        }
        swap(&arr, a: sortedIndex, b: right)
        return sortedIndex
    }
}
