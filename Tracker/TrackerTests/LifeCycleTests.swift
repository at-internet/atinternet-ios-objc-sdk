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
//  LifeCycleTests.swift
//


import UIKit
import XCTest

class LifeCycleTests: XCTestCase {

    let userDefaults = NSUserDefaults.standardUserDefaults()
    let dateFormatter = NSDateFormatter()
    var now: String?
    
    override func setUp() {
        super.setUp()
        
        ATLifeCycle.setInitialized(false)
        
        dateFormatter.dateFormat = "yyyyMMdd"
        now = dateFormatter.stringFromDate(NSDate())
        userDefaults.removeObjectForKey(APPLICATION_UPDATE)
        userDefaults.removeObjectForKey(FIRST_LAUNCH)
        userDefaults.removeObjectForKey(FIRST_LAUNCH_DATE)
        userDefaults.removeObjectForKey(LAST_APPLICATION_VERSION)
        userDefaults.removeObjectForKey(LAST_USE)
        userDefaults.removeObjectForKey(LAUNCH_COUNT)
        userDefaults.removeObjectForKey(LAUNCH_COUNT_SINCE_UPDATE)
        userDefaults.removeObjectForKey(LAUNCH_DAY_COUNT)
        userDefaults.removeObjectForKey(LAUNCH_MONTH_COUNT)
        userDefaults.removeObjectForKey(LAUNCH_WEEK_COUNT)
        
        userDefaults.synchronize()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testRetrieveSDKV1Lifecycle() {
        let now = NSDate()
        
        let oldLastUse: AnyObject? = userDefaults.objectForKey(LAST_USE)
        
        XCTAssertNil(oldLastUse, "oldLastUse doit être nil")
        
        userDefaults.setObject("20110201", forKey: "firstLaunchDate")
        userDefaults.setInteger(5, forKey: "ATLaunchCount")
        userDefaults.setObject(now, forKey: "lastUseDate")
        userDefaults.synchronize()
        
        let _ = ATLifeCycle()
        
        XCTAssert(userDefaults.objectForKey("firstLaunchDate") == nil, "firstLaunchDate doit être nil")
        XCTAssert(userDefaults.objectForKey(FIRST_LAUNCH) as! Int == 0, "firstLaunch doit être égale à 0")
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "YYYYMMdd"
        XCTAssert((userDefaults.objectForKey(FIRST_LAUNCH_DATE) as! NSDate) == dateFormatter.dateFromString("20110201"), "firstLaunchDate doit être égale à 20110201")
        XCTAssertNotNil(userDefaults.objectForKey(LAST_USE) as! NSDate, "LastUse ne doit pas etre nil")
        XCTAssert(userDefaults.objectForKey(LAUNCH_COUNT) as! Int == 6, "LaunchCount doit être égale à 6")
        
    }
    
    

    func testFirstLaunchAndFirstScreenHit() {
        let lifeCycle = ATLifeCycle()
        
        let stringData = lifeCycle.getMetrics()()
        let data = stringData.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
        
        let json = JSON(data: data!)
        
        XCTAssert(json["lifecycle"]["fl"].intValue == 1, "la variable fl doit être égale à 1")
        XCTAssert(json["lifecycle"]["flau"].intValue == 0, "la variable flau doit être égale à 0")
        XCTAssert(json["lifecycle"]["ldc"].intValue == 1, "la variable ldc doit être égale à 1")
        XCTAssert(json["lifecycle"]["lwc"].intValue == 1, "la variable lwc doit être égale à 1")
        XCTAssert(json["lifecycle"]["lmc"].intValue == 1, "la variable lmc doit être égale à 1")
        XCTAssert(json["lifecycle"]["fld"].intValue == Int(now!), "la variable fld doit être égale à aujourd'hui")
        XCTAssert(json["lifecycle"]["dsfl"].intValue == 0, "la variable dsfl doit être égale à 0")
        XCTAssert(json["lifecycle"]["dslu"].intValue == 0, "la variable dslu doit être égale à 0")
        XCTAssert(json["lifecycle"]["lc"].intValue == 1, "la variable lc doit être égale à 1")
    }
    
    func testDaysSinceFirstLaunch() {
        let today = NSDate()
        let dateComponent = NSDateComponents()
        dateComponent.day = -2
        
        let past = NSCalendar.currentCalendar().dateByAddingComponents(dateComponent, toDate: today, options: NSCalendarOptions(rawValue: 0))
        
        // Set first launch date two days in the past
        userDefaults.setInteger(1, forKey: FIRST_LAUNCH)
        userDefaults.setObject(past, forKey: FIRST_LAUNCH_DATE)
        
        let lifeCycle = ATLifeCycle()
        
        let stringData = lifeCycle.getMetrics()()
        let data = stringData.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
        
        let json = JSON(data: data!)

        XCTAssert(json["lifecycle"]["dsfl"].intValue == 2, "la variable dsfl doit être égale à 0")
    }
    
    func testDaysSinceLastUse() {
        let today = NSDate()
        let dateComponent = NSDateComponents()
        dateComponent.day = -10
        
        let past = NSCalendar.currentCalendar().dateByAddingComponents(dateComponent, toDate: today, options: NSCalendarOptions(rawValue: 0))
        
        // Set first launch date two days in the past
        userDefaults.setInteger(1, forKey: FIRST_LAUNCH)
        userDefaults.setObject(past, forKey: FIRST_LAUNCH_DATE)
        userDefaults.setObject(past, forKey: LAST_USE)
        
        let lifeCycle = ATLifeCycle()
        
        let stringData = lifeCycle.getMetrics()()
        let data = stringData.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
        
        let json = JSON(data: data!)
        
        print(json)
        
        XCTAssert(json["lifecycle"]["dslu"].intValue == 10, "la variable dslu doit être égale à 0")
    }
    
    func testLaunchCount() {
        let today = NSDate()
        userDefaults.setInteger(1, forKey: FIRST_LAUNCH)
        userDefaults.setObject(today, forKey: FIRST_LAUNCH_DATE)
        userDefaults.setInteger(10, forKey: LAUNCH_COUNT)
        userDefaults.synchronize()
        
        let lifeCycle = ATLifeCycle()
        
        let stringData = lifeCycle.getMetrics()()
        let data = stringData.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
        
        let json = JSON(data: data!)
        
        XCTAssert(json["lifecycle"]["lc"].intValue == 11, "la variable lc doit être égale à 11")
    }
    
    func testLaunchDayCount() {
        let lifeCycle = ATLifeCycle()
        
        let stringData = lifeCycle.getMetrics()()
        let data = stringData.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
        
        let json = JSON(data: data!)
        
        XCTAssert(json["lifecycle"]["ldc"].intValue == 1, "la variable ldc doit être égale à 1")
    }
    
    func testLaunchDayCountSinceSameDay() {
        // Set last use to now in the past
        let today = NSDate()
        userDefaults.setInteger(1, forKey: FIRST_LAUNCH)
        userDefaults.setObject(today, forKey: FIRST_LAUNCH_DATE)
        userDefaults.setObject(today, forKey: LAST_USE)
        userDefaults.setInteger(5, forKey: LAUNCH_DAY_COUNT)
        userDefaults.synchronize()
        
        let lifeCycle = ATLifeCycle()
        
        let stringData = lifeCycle.getMetrics()()
        let data = stringData.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
        
        let json = JSON(data: data!)

        XCTAssert(json["lifecycle"]["ldc"].intValue == 6, "la variable ldc doit être égale à 6")
    }
    
    func testLaunchDayCountSinceLastUseInPast() {
        let today = NSDate()
        let dateComponent = NSDateComponents()
        dateComponent.day = -10
        
        let past = NSCalendar.currentCalendar().dateByAddingComponents(dateComponent, toDate: today, options: NSCalendarOptions(rawValue: 0))
        
        // Set last use 10 days in the past
        userDefaults.setObject(past, forKey: LAST_USE)
        userDefaults.setObject(5, forKey: LAUNCH_DAY_COUNT)
        userDefaults.synchronize()
        
        let lifeCycle = ATLifeCycle()
        
        let stringData = lifeCycle.getMetrics()()
        let data = stringData.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
        
        let json = JSON(data: data!)
        
        XCTAssert(json["lifecycle"]["ldc"].intValue == 1, "la variable ldc doit être égale à 1")
    }
    
    func testLaunchMonthCount() {
        let lifeCycle = ATLifeCycle()
        
        let stringData = lifeCycle.getMetrics()()
        let data = stringData.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
        
        let json = JSON(data: data!)
        
        XCTAssert(json["lifecycle"]["lmc"].intValue == 1, "la variable ldc doit être égale à 1")
    }
    
    func testLaunchMonthCountSinceSameDay() {
        // Set last use to now in the past
        let today = NSDate()
        userDefaults.setInteger(1, forKey: FIRST_LAUNCH)
        userDefaults.setObject(today, forKey: FIRST_LAUNCH_DATE)
        userDefaults.setObject(today, forKey: LAST_USE)
        userDefaults.setInteger(5, forKey: LAUNCH_MONTH_COUNT)
        userDefaults.synchronize()
        
        let lifeCycle = ATLifeCycle()
        
        let stringData = lifeCycle.getMetrics()()
        let data = stringData.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
        
        let json = JSON(data: data!)
        
        XCTAssert(json["lifecycle"]["lmc"].intValue == 6, "la variable lmc doit être égale à 6")
    }
    
    func testLaunchMonthCountSinceLastUseInPast() {
        let today = NSDate()
        let dateComponent = NSDateComponents()
        dateComponent.day = -32
        
        let past = NSCalendar.currentCalendar().dateByAddingComponents(dateComponent, toDate: today, options: NSCalendarOptions(rawValue: 0))
        
        // Set last use 10 days in the past
        userDefaults.setObject(past, forKey: LAST_USE)
        userDefaults.setObject(5, forKey: LAUNCH_MONTH_COUNT)
        userDefaults.synchronize()
        
        let lifeCycle = ATLifeCycle()
        
        let stringData = lifeCycle.getMetrics()()
        let data = stringData.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
        
        let json = JSON(data: data!)
        
        XCTAssert(json["lifecycle"]["lmc"].intValue == 1, "la variable lmc doit être égale à 1")
    }
    
    func testLaunchWeekCount() {
        let lifeCycle = ATLifeCycle()
        
        let stringData = lifeCycle.getMetrics()()
        let data = stringData.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
        
        let json = JSON(data: data!)
        
        XCTAssert(json["lifecycle"]["lwc"].intValue == 1, "la variable lwc doit être égale à 1")
    }
    
    func testLaunchWeekCountSinceSameDay() {
        // Set last use to now in the past
        let today = NSDate()
        userDefaults.setInteger(1, forKey: FIRST_LAUNCH)
        userDefaults.setObject(today, forKey: FIRST_LAUNCH_DATE)
        userDefaults.setObject(today, forKey: LAST_USE)
        userDefaults.setInteger(5, forKey: LAUNCH_WEEK_COUNT)
        userDefaults.synchronize()
        
        let lifeCycle = ATLifeCycle()
        
        let stringData = lifeCycle.getMetrics()()
        let data = stringData.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
        
        let json = JSON(data: data!)
        
        XCTAssert(json["lifecycle"]["lwc"].intValue == 6, "la variable lwc doit être égale à 6")
    }
    
    func testLaunchWeekCountSinceLastUseInPast() {
        let today = NSDate()
        let dateComponent = NSDateComponents()
        dateComponent.day = -7
        
        let past = NSCalendar.currentCalendar().dateByAddingComponents(dateComponent, toDate: today, options: NSCalendarOptions(rawValue: 0))
        
        // Set last use 10 days in the past
        userDefaults.setObject(past, forKey: LAST_USE)
        userDefaults.setObject(5, forKey: LAUNCH_WEEK_COUNT)
        userDefaults.synchronize()
        
        let lifeCycle = ATLifeCycle()
        
        let stringData = lifeCycle.getMetrics()()
        let data = stringData.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
        
        let json = JSON(data: data!)
        
        XCTAssert(json["lifecycle"]["lwc"].intValue == 1, "la variable lwc doit être égale à 1")
    }
    
    func testFirstLaunchAfterUpdate() {
        let today = NSDate()
        userDefaults.setInteger(1, forKey: FIRST_LAUNCH)
        userDefaults.setObject(today, forKey: FIRST_LAUNCH_DATE)
        userDefaults.setObject("[0.0]", forKey: LAST_APPLICATION_VERSION)
        userDefaults.synchronize()
        
        let lifeCycle = ATLifeCycle()
        
        let stringData = lifeCycle.getMetrics()()
        let data = stringData.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
        
        let json = JSON(data: data!)
        
        XCTAssert(json["lifecycle"]["flau"].intValue == 1, "la variable flai doit être égale à 1")
        XCTAssert(json["lifecycle"]["uld"].intValue == Int(now!), "la variable uld doit être égale à aujourd'hui")
        XCTAssert(json["lifecycle"]["lcsu"].intValue == 1, "la variable lcsu doit être égale à 1")
        XCTAssert(json["lifecycle"]["dsu"].intValue == 0, "la variable dsu doit être égale à 0")
    }
    
    func testUpdateLaunchCount() {
        let today = NSDate()
        userDefaults.setInteger(1, forKey: FIRST_LAUNCH)
        userDefaults.setObject(today, forKey: FIRST_LAUNCH_DATE)
        userDefaults.setObject("[1.0]", forKey: LAST_APPLICATION_VERSION)
        userDefaults.setInteger(10, forKey: LAUNCH_COUNT_SINCE_UPDATE)
        userDefaults.synchronize()
        
        let lifeCycle = ATLifeCycle()
        
        let stringData = lifeCycle.getMetrics()()
        let data = stringData.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
        
        let json = JSON(data: data!)
        
        XCTAssert(json["lifecycle"]["lcsu"].intValue == 11, "la variable lcsu doit être égale à 11")
    }
    
    func testDaysSinceUpdate() {
        let today = NSDate()
        let dateComponent = NSDateComponents()
        dateComponent.day = -7
        
        let past = NSCalendar.currentCalendar().dateByAddingComponents(dateComponent, toDate: today, options: NSCalendarOptions(rawValue: 0))
        
        userDefaults.setObject(past, forKey: APPLICATION_UPDATE)
        userDefaults.synchronize()
        
        let lifeCycle = ATLifeCycle()
        
        let stringData = lifeCycle.getMetrics()()
        let data = stringData.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
        
        let json = JSON(data: data!)
        
        XCTAssert(json["lifecycle"]["dsu"].intValue == 7, "la variable dsu doit être égale à 7")
    }
    
    func testSecondSinceBackground() {
        let now = NSDate()
        let nowWith65 = NSDate().dateByAddingTimeInterval(65)
        let delta = ATTool.secondsBetweenDates(now, toDate: nowWith65)
        XCTAssert(delta == 65)
    }
}
