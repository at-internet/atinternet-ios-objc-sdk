/*
This SDK is licensed under the MIT license (MIT)
Copyright (c) 2015- Applied Technologies Internet SAS (registration number B 403 261 258 - Trade and Companies Register of Bordeaux – France)

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
*/





//
//  TVTrackingTests.swift
//


import UIKit
import XCTest

class TVTrackingTests: XCTestCase {

    let tracker = ATTracker();
    
    func testSetTVTNotEnabled() {
        let expectation = expectationWithDescription("test")
        
        tracker.setConfig("plugins", value: "", completionHandler: nil)
        tracker.tvTracking.set()
        let configurationOperation = NSBlockOperation(block: {
            XCTAssertTrue(self.tracker.buffer.volatileParameters.count == 0, "Le paramètre TV Tracking ne doit pas être ajouté")
            expectation.fulfill()
        })
        
        ATTrackerQueue.sharedInstance().queue.addOperation(configurationOperation)
        
        waitForExpectationsWithTimeout(10, handler: nil)
    }
    
    func testSetTVTEnabled() {
        let expectation = expectationWithDescription("test")
        
        tracker.setConfig("plugins", value: "tvtracking", completionHandler: nil)
        tracker.tvTracking.set()
        let configurationOperation = NSBlockOperation(block: {
            let p0 = self.tracker.buffer.persistentParameters.lastObject as! ATParam
            XCTAssertTrue(p0.key == "tvt", "Le paramètre doit être la clé du plugin TV Tracking")
            XCTAssertTrue(p0.value() == "true", "La valeur doit être true")
            expectation.fulfill()
        })
        
        ATTrackerQueue.sharedInstance().queue.addOperation(configurationOperation)
        
        waitForExpectationsWithTimeout(10, handler: nil)
    }

}
