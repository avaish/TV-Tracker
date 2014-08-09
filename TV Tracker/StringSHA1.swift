//
//  StringSHA1.swift
//  TV Tracker
//
//  Created by Atharv Vaish on 7/14/14.
//  Copyright (c) 2014 Atharv Vaish. All rights reserved.
//

import Foundation

extension String {
    func sha1() -> String! {
        let str = self.cStringUsingEncoding(NSUTF8StringEncoding)
        let strLen = CUnsignedInt(self.lengthOfBytesUsingEncoding(NSUTF8StringEncoding))
        let digestLen = Int(CC_SHA1_DIGEST_LENGTH)
        let result = UnsafeMutablePointer<CUnsignedChar>.alloc(digestLen)
        
        CC_SHA1(str!, strLen, result)
        
        var hash = NSMutableString()
        for i in 0..<digestLen {
            hash.appendFormat("%02x", result[i])
        }
        
        result.destroy()
        return String(format: hash)
    }
}