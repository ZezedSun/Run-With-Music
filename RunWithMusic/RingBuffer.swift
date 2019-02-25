//
//  RingBuffer.swift
//  RunWithMusic
//
//  Created by Jiayin  Liu on 12/9/18.
//  Copyright © 2018 Mingze Sun. All rights reserved.
//

import Foundation

let BUFFER_SIZE = 50

class RingBuffer: NSObject {
    
    var x = [Double](repeating:0, count:BUFFER_SIZE)
    
    var head:Int = 0 {
        didSet{
            if(head >= BUFFER_SIZE){
                head = 0
            }
            
        }
    }
    
    func addNewData(xData:Double){
        x[head] = xData
        head += 1
    }
    
    func getDataAsVector()->[Double]{
        var allVals = [Double](repeating:0, count:BUFFER_SIZE)
        
        for i in 0..<BUFFER_SIZE {
            let idx = (head+i)%BUFFER_SIZE
            allVals[i] = x[idx]
        }
        return allVals
    }
    
    
    
}
