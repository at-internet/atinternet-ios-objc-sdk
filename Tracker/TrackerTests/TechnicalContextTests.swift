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
//  TechnicalContextTests.swift
//


import UIKit
import XCTest

class TechnicalContextTests: XCTestCase {

    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }

    /* On test les différentes possiblités de récupération d'un id client */
    
    func testIDFV() {
        let ref = UIDevice.currentDevice().identifierForVendor!.UUIDString
        XCTAssertNotNil(ref, "IDFV shall not be nil")
        XCTAssertEqual(ref, ATTechnicalContext.userId("idfv"), "Unique identifier shall be equal to IDFV")
    }
    
    func testExistingUUID() {
        let ref = NSUUID().UUIDString
        NSUserDefaults.standardUserDefaults().setObject(ref, forKey: "ApplicationUniqueIdentifier")
        NSUserDefaults.standardUserDefaults().synchronize()
        XCTAssertNotNil(ref, "UUID shall not be nil")
        XCTAssertEqual(ref, ATTechnicalContext.userId("whatever"), "Unique identifier shall be equal to existing UUID")
    }
    
    func testNonExistingUUID() {
        NSUserDefaults.standardUserDefaults().removeObjectForKey("ApplicationUniqueIdentifier")
        NSUserDefaults.standardUserDefaults().synchronize()
        XCTAssertEqual(36, ATTechnicalContext.userId("whatever").characters.count, "Unique identifier shall be a new valid UUID")
    }
    
    func testUserIdWithNilConfiguration() {
        NSUserDefaults.standardUserDefaults().removeObjectForKey("ApplicationUniqueIdentifier")
        NSUserDefaults.standardUserDefaults().synchronize()
        XCTAssertEqual(36, ATTechnicalContext.userId(nil).characters.count, "Unique identifier shall be a new valid UUID")
    }
    
    func testSDKVersion() {
        XCTAssertNotNil(ATTechnicalContext.sdkVersion(), "SDK version shall not be nil")
        XCTAssertNotEqual("", ATTechnicalContext.sdkVersion(), "SDK version shall not have an empty string value")
    }
    
    func testLanguage() {
        XCTAssertNotNil(ATTechnicalContext.language(), "Language shall not be nil")
        XCTAssertNotEqual("", ATTechnicalContext.language(), "Language shall not have an empty string value")
    }
    
    func testDevice() {
        XCTAssertNotNil(ATTechnicalContext.device(), "Device shall not be nil")
        XCTAssertNotEqual("", ATTechnicalContext.device(), "Device shall not have an empty string value")
    }
    
    func testApplicationIdentifier() {
        XCTAssertNotNil(ATTechnicalContext.applicationIdentifier(), "Application identifier shall not be nil")
    }
    
    func testApplicationVersion() {
        XCTAssertNotNil(ATTechnicalContext.applicationVersion(), "Application version shall not be nil")
    }
    
    func testLocalHour() {
        XCTAssertNotNil(ATTechnicalContext.localHour(), "Local hour shall not be nil")
        XCTAssertNotEqual("", ATTechnicalContext.localHour(), "Local hour shall not have an empty string value")
    }
    
    func testScreenResolution() {
        XCTAssertNotNil(ATTechnicalContext.screenResolution(), "Screen resolution shall not be nil")
        XCTAssertNotEqual("", ATTechnicalContext.screenResolution(), "Screen resolution shall not have an empty string value")
    }
    
    func testCarrier() {
        XCTAssertNotNil(ATTechnicalContext.carrier(), "Carrier shall not be nil")
    }
    
    func testConnectionType() {
        XCTAssertTrue(ATTechnicalContext.connectionType().rawValue >= 0, "Connection type shall be superior or equal to 0")
    }
}
