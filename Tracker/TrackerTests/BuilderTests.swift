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
//  BuilderTests.swift
//


import UIKit
import XCTest

class BuilderTests: XCTestCase, ATTrackerDelegate {
    
    func trackerNeedsFirstLaunchApproval(message: String) {
        print(message)
    }
    
    func buildDidEnd(status: ATHitStatus, message: String) {
        print(message)
    }
    
    func sendDidEnd(status: ATHitStatus, message: String) {
        print(message)
    }
    
    func saveDidEnd(message: String) {

    }
    
    func didCallPartner(response: String, semaphore: dispatch_semaphore_t) {
        print(response)
    }
    
    func warningDidOccur(message: String) {
        print(message)
    }
    
    func errorDidOccur(message: String) {
        print(message)
    }
    
    let tracker = ATTracker()
    let conf = ["log":"logp", "logSSL":"logs", "domain":"xiti.com", "pixelPath":"/hit.xiti", "site":"549808", "secure":"false", "identifier":"uuid"]
    
    override func setUp() {
        super.setUp()
        tracker.setConfig(conf, override: false, completionHandler: nil)
        tracker.delegate = self
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func getDate() -> String {
        let date = NSDate()
        let formatter = NSDateFormatter()
        formatter.dateStyle = .ShortStyle
        return formatter.stringFromDate(date)
    }
    
    // Teste que le hit construit avec une paramètre dont la valeur est une closure contient bien le résultat attendu
    func testBuildHitWithClosureParam() {
        
        let today = getDate()
        
        let pageParam = ATParam("p", value: {"home"}, type: .String)
        let hlParam = ATParam("date", value: {self.getDate()}, type: .String)
        
        tracker.buffer.volatileParameters.addObject(pageParam)
        tracker.buffer.volatileParameters.addObject(hlParam)
        
        let volPar = tracker.buffer.volatileParameters as [AnyObject]
        let perPar = tracker.buffer.persistentParameters as [AnyObject]
        
        let builder = ATBuilder(tracker: self.tracker, volatileParameters: volPar, persistentParameters: perPar)
        
        let hits = builder.build()
        let url = NSURL(string: hits[0] as! String)
        
        _ = [String: String]()
        let urlComponents = url?.absoluteString!.componentsSeparatedByString("&")
        
        for component in urlComponents! as [String] {
            let pairComponents = component.componentsSeparatedByString("=")
            
            if(pairComponents[0] == "p") {
                XCTAssert(pairComponents[1] == "home", "le paramètre p doit être égal à home")
            } else if(pairComponents[0] == "date"){
                XCTAssert(pairComponents[1] == today, "le paramètre date doit être égal à getDate()")
            }
        }
    }
    
    // Teste que le hit construit avec une paramètre dont la valeur est un float contient bien le résultat attendu
    func testBuildHitWithFloatParam() {
        
        _ = getDate()
        
        let value = {ATTool.convertToString(3.1415, separator: nil).value}
        let floatParam = ATParam("float", value: value, type: .Float)

        tracker.buffer.volatileParameters.addObject(floatParam)
        
        let volPar = tracker.buffer.volatileParameters as [AnyObject]
        let perPar = tracker.buffer.persistentParameters as [AnyObject]
        
        let builder = ATBuilder(tracker: self.tracker, volatileParameters: volPar, persistentParameters: perPar)
        
        let hits = builder.build()
        let url = NSURL(string: hits[0] as! String)
        
        _ = [String: String]()
        let urlComponents = url?.absoluteString!.componentsSeparatedByString("&")
        
        for component in urlComponents! as [String] {
            let pairComponents = component.componentsSeparatedByString("=")
            
            if(pairComponents[0] == "float"){
                XCTAssert(pairComponents[1] == "3.1415", "le paramètre float doit être égal à 3.1415")
                
                break
            }
        }
    }
    
    // Teste que le hit construit avec une paramètre dont la valeur est un int contient bien le résultat attendu
    func testBuildHitWithIntParam() {
        
        _ = getDate()
        let value = {ATTool.convertToString(3, separator: nil).value}
        let intParam = ATParam("int", value: value, type: .Integer)
        
        tracker.buffer.volatileParameters.addObject(intParam)
        
        let volPar = tracker.buffer.volatileParameters as [AnyObject]
        let perPar = tracker.buffer.persistentParameters as [AnyObject]
        
        let builder = ATBuilder(tracker: self.tracker, volatileParameters: volPar, persistentParameters: perPar)
        
        let hits = builder.build()
        let url = NSURL(string: hits[0] as! String)
        
        _ = [String: String]()
        let urlComponents = url?.absoluteString!.componentsSeparatedByString("&")
        
        for component in urlComponents! as [String] {
            let pairComponents = component.componentsSeparatedByString("=")
            
            if(pairComponents[0] == "int"){
                XCTAssert(pairComponents[1] == "3".percentEncodedString, "le paramètre int doit être égal à 3")
                
                break
            }
        }
    }
    
    // Teste que le hit construit avec une paramètre dont la valeur est un bool contient bien le résultat attendu
    func testBuildHitWithBoolParam() {
        
        _ = getDate()

        let valueT = {ATTool.convertToString(true, separator: nil).value}
        let valueF = {ATTool.convertToString(false, separator: nil).value}
        let trueBoolParam = ATParam("trueBool", value: valueT, type: .Bool)
        let falseBoolParam = ATParam("falseBool", value: valueF, type: .Bool)
        
        tracker.buffer.volatileParameters.addObject(trueBoolParam)
        tracker.buffer.volatileParameters.addObject(falseBoolParam)
        
        let volPar = tracker.buffer.volatileParameters as [AnyObject]
        let perPar = tracker.buffer.persistentParameters as [AnyObject]
        
        let builder = ATBuilder(tracker: self.tracker, volatileParameters: volPar, persistentParameters: perPar)
        
        let hits = builder.build()
        let url = NSURL(string: hits[0] as! String)
        
        _ = [String: String]()
        let urlComponents = url?.absoluteString!.componentsSeparatedByString("&")
        
        for component in urlComponents! as [String] {
            let pairComponents = component.componentsSeparatedByString("=")
            
            if(pairComponents[0] == "trueBool"){
                XCTAssert(pairComponents[1] == "true".percentEncodedString, "le paramètre trueBool doit être égal à true")
                
                break
            }
            
            if pairComponents.count > 1 {
                if(pairComponents[1] == "falseBool"){
                    XCTAssert(pairComponents[1] == "false".percentEncodedString, "le paramètre falseBool doit être égal à false")
                    
                    break
                }
            }
        }
    }
    
    // Teste que le hit construit avec une paramètre dont la valeur est un dictionnaire contient bien le résultat attendu
    func testBuildHitWithDictionnaryParam() {
        
        _ = getDate()
        let option = ATParamOption()
        option.encode = true
        
        let value = {ATTool.convertToString(
            ["légume":["chou","patate","tomate","carotte"], "fruits": ["pomme", "abricot", "poire"]],
            separator: nil).value}
        let dictParam = ATParam("json", value:value, type: .JSON, options:option)

        tracker.buffer.volatileParameters.addObject(dictParam)
        
        let volPar = tracker.buffer.volatileParameters as [AnyObject]
        let perPar = tracker.buffer.persistentParameters as [AnyObject]
        
        let builder = ATBuilder(tracker: self.tracker, volatileParameters: volPar, persistentParameters: perPar)
        
        let hits = builder.build()
        let url = NSURL(string: hits[0] as! String)
        
        _ = [String: String]()
        let urlComponents = url?.absoluteString!.componentsSeparatedByString("&")
        
        for component in urlComponents! as [String] {
            let pairComponents = component.componentsSeparatedByString("=")
            
            if(pairComponents[0] == "json"){
                XCTAssert(pairComponents[1] == dictParam.value().percentEncodedString, "le paramètre json doit être égal à {\"fruits\":[\"pomme\",\"abricot\",\"poire\"],\"légume\":[\"chou\",\"patate\",\"tomate\",\"carotte\"]}")
                
                break
            }
        }
    }
    
    // Teste que le hit construit avec une paramètre dont la valeur est un tableau contient bien le résultat attendu
    func testBuildHitWithArrayParam() {
        _ = getDate()

        let value = {ATTool.convertToString(["chou","patate","tomate","carotte"], separator: nil).value}
        let arrayParam = ATParam("array", value: value, type: .String)
        
        tracker.buffer.volatileParameters.addObject(arrayParam)
        
        let volPar = tracker.buffer.volatileParameters as [AnyObject]
        let perPar = tracker.buffer.persistentParameters as [AnyObject]
        
        let builder = ATBuilder(tracker: self.tracker, volatileParameters: volPar, persistentParameters: perPar)
        
        let hits = builder.build()
        let url = NSURL(string: hits[0] as! String)
        
        _ = [String: String]()
        let urlComponents = url?.absoluteString!.componentsSeparatedByString("&")
        
        for component in urlComponents! as [String] {
            let pairComponents = component.componentsSeparatedByString("=")
            
            if(pairComponents[0] == "array"){
                XCTAssert(pairComponents[1] == arrayParam.value(), "le paramètre json doit être égal à chou,patate,tomate,carotte")
                
                break
            }
        }
    }

    // Teste que le hit construit avec une paramètre dont la valeur est un tableau et le separator |contient bien le résultat attendu
    func testBuildHitWithArrayParamAndPipeSeparator() {
        
        _ = getDate()

        let arrayOption = ATParamOption()
        arrayOption.separator = "|"
        
        let value = {ATTool.convertToString(["chou","patate","tomate","carotte"], separator: nil).value}
        let arrayParam = ATParam("array", value: value, type: .String, options:arrayOption)
        
        tracker.buffer.volatileParameters.addObject(arrayParam)
        
        let volPar = tracker.buffer.volatileParameters as [AnyObject]
        let perPar = tracker.buffer.persistentParameters as [AnyObject]
        
        let builder = ATBuilder(tracker: self.tracker, volatileParameters: volPar, persistentParameters: perPar)
        
        let hits = builder.build()
        let url = NSURL(string: hits[0] as! String)
        
        _ = [String: String]()
        let urlComponents = url?.absoluteString!.componentsSeparatedByString("&")
        
        for component in urlComponents! as [String] {
            let pairComponents = component.componentsSeparatedByString("=")
            
            if(pairComponents[0] == "array"){
                XCTAssert(pairComponents[1] == arrayParam.value(), "le paramètre json doit être égal à chou|patate|tomate|carotte")
                
                break
            }
        }
    }
    
    // Teste l'envoi d'un hit
    /*
    func testSendHit() {
        _ = [ATParam]()
        
        let pageParam = ATParam("p", value: {"home"}, type: .String)
        
        let valueS = {ATTool.convertToString(
            ["légume":["chou","patate","tomate","carotte"], "fruits": ["pomme", "abricot", "poire"]],
            separator: nil).value}
        let valueA = {ATTool.convertToString(
            ["chou", "choux-fleur"],
            separator: nil).value}
        
        let option = ATParamOption()
        option.encode = true
        
        let stcParam = ATParam("stc", value: valueS, type: .JSON, options:option)
        let arrayParam = ATParam("array", value: valueA, type: .String, options:option)
        
        let refParamOptions = ATParamOption()
        refParamOptions.relativePosition = .Last

        let refParam = ATParam("ref", value: {"www.atinternet.com"}, type: .String, options: refParamOptions)
        
        let valueDslu = {ATTool.convertToString(10, separator: nil).value}
        let dsluParam = ATParam("dslu", value: valueDslu, type: .Integer)
        
        let crashParamOptions = ATParamOption()
        crashParamOptions.relativePosition = .After
        crashParamOptions.relativeParameterKey = "stc"
        
        let valueCrash = {ATTool.convertToString(false, separator: nil).value}
        let crashParam = ATParam("crash", value: valueCrash, type: .Bool, options: crashParamOptions)
        
        tracker.buffer.volatileParameters.addObject(pageParam)
        tracker.buffer.volatileParameters.addObject(stcParam)
        tracker.buffer.volatileParameters.addObject(refParam)
        tracker.buffer.volatileParameters.addObject(dsluParam)
        tracker.buffer.volatileParameters.addObject(crashParam)
        tracker.buffer.volatileParameters.addObject(arrayParam)
        
        let volPar = tracker.buffer.volatileParameters as [AnyObject]
        let perPar = tracker.buffer.persistentParameters as [AnyObject]
        
        let builder = ATBuilder(tracker: self.tracker, volatileParameters: volPar, persistentParameters: perPar)
        
        let expectation = self.expectationWithDescription("Hit sent")
        
        let hits = builder.build()
        let hit = ATHit(hits[0] as! String)
        let sender = ATSender(tracker: tracker, hit: hit, forceSendOfflineHits:false, mhOlt: nil)
        
        sender.sendWithCompletionHandler({(success) in
            XCTAssert(success, "Hit could not be sent")
            expectation.fulfill()
        })
        
        self.waitForExpectationsWithTimeout(5.0, handler: nil)
    }*/

    // Teste que la méthode findParameterPosition retourne la bonne position du paramètre dans la collection
    func testFindParameterPosition() {
        var parameters = [ATParam]()
        let pageParam = ATParam("p", value: {"home"}, type: .String)
        let value = {ATTool.convertToString(["chou", "patate", "carotte"], separator: nil).value}
        let stcParam = ATParam("stc", value: value, type: .String)
        let refParamOptions = ATParamOption()
        refParamOptions.relativePosition = .Last
        
        let refParam = ATParam("ref", value: {"www.atinternet.com?test1=1&test2=2&test3=<script></script>"}, type: .String, options: refParamOptions)
        let valueDslu = {ATTool.convertToString(10, separator: nil).value}
        let dsluParam = ATParam("dslu", value: valueDslu, type: .Integer)
        let crashParamOptions = ATParamOption()
        crashParamOptions.relativePosition = .After
        crashParamOptions.relativeParameterKey = "stc"
        
        let valueCrash = {ATTool.convertToString(false, separator: nil).value}
        let crashParam = ATParam("crash", value: valueCrash, type: .Bool, options: crashParamOptions)
        let hlParam = ATParam("hl", value: {self.getDate()}, type: .String)
        
        parameters.append(pageParam)
        parameters.append(stcParam)
        parameters.append(refParam)
        parameters.append(dsluParam)
        parameters.append(crashParam)
        parameters.append(hlParam)
        
        let templateParameters = [parameters]
        
        
        let posPageParam = (ATTool.findParameterPosition("p", array: templateParameters).first as! ATParamBufferPosition).index
        let posStcParam = (ATTool.findParameterPosition("stc", array: templateParameters).first as! ATParamBufferPosition).index
        let posRefParam = (ATTool.findParameterPosition("ref", array: templateParameters).first as! ATParamBufferPosition).index
        let posDsluParam = (ATTool.findParameterPosition("dslu", array: templateParameters).first as! ATParamBufferPosition).index
        let posCrashParam = (ATTool.findParameterPosition("crash", array: templateParameters).first as! ATParamBufferPosition).index
        let posHlParam = (ATTool.findParameterPosition("hl", array: templateParameters).first as! ATParamBufferPosition).index
        
        XCTAssert(posPageParam == 0, "le paramètre p aurait du être en position 0")
        XCTAssert(posStcParam == 1, "le paramètre stc aurait du être en position 1")
        XCTAssert(posRefParam == 2, "le paramètre ref aurait du être en position 2")
        XCTAssert(posDsluParam == 3, "le paramètre dslu aurait du être en position 3")
        XCTAssert(posCrashParam == 4, "le paramètre crash aurait du être en position 4")
        XCTAssert(posHlParam == 5, "le paramètre hl aurait du être en position 5")
    }
    
    // Teste que la méthode makeSubQuery formatte correctement les paramètres sous la forme &p=v
    func testMakeSubQuery() {
        let volPar = tracker.buffer.volatileParameters as [AnyObject]
        let perPar = tracker.buffer.persistentParameters as [AnyObject]
        
        let builder = ATBuilder(tracker: self.tracker, volatileParameters: volPar, persistentParameters: perPar)
        let queryString = builder.makeSubQueryForParameter("p", value: "home")
        
        XCTAssert(queryString == "&p=home", "la querystring doit être égale à p=home")
    }
    
    // Teste le formattage de paramètres volatiles
    func testPreQueryWithVolatileParameters() {
        _ = [ATParam]()
        let pageParam = ATParam("p", value: {"home"}, type: .String)
        let valueStc = {ATTool.convertToString(["légume":["chou","patate","tomate","carotte"], "fruits": ["pomme", "abricot", "poire"]], separator: nil).value}
        
        let option = ATParamOption()
        option.encode = true
        let stcParam = ATParam("stc", value: valueStc, type: .String, options:option)
        
        let refParamOption = ATParamOption()
        refParamOption.relativePosition = .Last
        
        let refParam = ATParam("ref", value: {"www.atinternet.com?test1=1&test2=2&test3=<script></script>"}, type: .String, options: refParamOption)
        let valueDslu = {ATTool.convertToString(10, separator: nil).value}
        let dsluParam = ATParam("dslu", value: valueDslu, type: .Integer)
        let valueCrash = {ATTool.convertToString(false, separator: nil).value}
        let crashParam = ATParam("crash", value: valueCrash, type: .Bool)
        
        tracker.buffer.volatileParameters.addObject(pageParam)
        tracker.buffer.volatileParameters.addObject(stcParam)
        tracker.buffer.volatileParameters.addObject(refParam)
        tracker.buffer.volatileParameters.addObject(dsluParam)
        tracker.buffer.volatileParameters.addObject(crashParam)
        
        let volPar = tracker.buffer.volatileParameters as [AnyObject]
        let perPar = tracker.buffer.persistentParameters as [AnyObject]
        
        let builder = ATBuilder(tracker: self.tracker, volatileParameters: volPar, persistentParameters: perPar)
        
        let strings = builder.prepareQuery() as NSArray
        
        XCTAssert(strings[14].str == "&p=home", "le premier paramètre doit être égal à &p=home")
        /*XCTAssert(strings[14].str == "&stc=%7B%22fruits%22%3A%5B%22pomme%22%2C%22abricot%22%2C%22poire%22%5D%2C%22l%C3%A9gume%22%3A%5B%22chou%22%2C%22patate%22%2C%22tomate%22%2C%22carotte%22%5D%7D", "le second paramètre doit être égal à &stc=chou%2Cpatate%2Ccarotte")*/
        XCTAssert(strings[16].str == "&dslu=10", "le paramètre dslu doit être égal à &dslu=10")
        XCTAssert(strings[17].str == "&crash=false", "le paramètre crash doit être égal à &crash=false")
        XCTAssert(strings[18].str == "&ref=www.atinternet.com?test1=1$test2=2$test3=script/script", "le paramètre ref doit être égal à &ref=www.atinternet.com et doit être le dernier paramètre")
    }
    
    // Teste le formattage de paramètres permanents
    func testPreQueryWithPersistentParameters() {
        _ = [ATParam]()
        let pageParam = ATParam("p", value: {"home"}, type: .String)
        
        let valueStc = {ATTool.convertToString(["légume":["chou","patate","tomate","carotte"], "fruits": ["pomme", "abricot", "poire"]], separator: nil).value}
        let option = ATParamOption()
        option.encode = true
        let stcParam = ATParam("stc", value: valueStc, type: .String, options:option)
        
        let refParamOption = ATParamOption()
        refParamOption.relativePosition = .Last
        
        let refParam = ATParam("ref", value: {"www.atinternet.com?test1=1&test2=2&test3=<script></script>"}, type: .String, options: refParamOption)
        let valueDslu = {ATTool.convertToString(10, separator: nil).value}
        let dsluParam = ATParam("dslu", value: valueDslu, type: .Integer)
        let valueCrash = {ATTool.convertToString(true, separator: nil).value}
        let crashParam = ATParam("crash", value: valueCrash, type: .Bool)
        
        tracker.buffer.persistentParameters.addObject(pageParam)
        tracker.buffer.persistentParameters.addObject(stcParam)
        tracker.buffer.persistentParameters.addObject(refParam)
        tracker.buffer.persistentParameters.addObject(dsluParam)
        tracker.buffer.persistentParameters.addObject(crashParam)
        
        let volPar = tracker.buffer.volatileParameters as [AnyObject]
        let perPar = tracker.buffer.persistentParameters as [AnyObject]
        
        let builder = ATBuilder(tracker: self.tracker, volatileParameters: volPar, persistentParameters: perPar)
        
        var strings = builder.prepareQuery()
        
        XCTAssert(strings[14].str == "&p=home", "le premier paramètre doit être égal à &p=home")
        /*XCTAssert(strings[14].str == "&stc=%7B%22fruits%22%3A%5B%22pomme%22%2C%22abricot%22%2C%22poire%22%5D%2C%22l%C3%A9gume%22%3A%5B%22chou%22%2C%22patate%22%2C%22tomate%22%2C%22carotte%22%5D%7D", "le second paramètre doit être égal à &stc=chou%2Cpatate%2Ccarotte")*/
        XCTAssert(strings[16].str == "&dslu=10", "le paramètre dslu doit être égal à &dslu=10")
        XCTAssert(strings[17].str == "&crash=true", "le paramètre crash doit être égal à &crash=true")
        XCTAssert(strings[18].str == "&ref=www.atinternet.com?test1=1$test2=2$test3=script/script", "le paramètre ref doit être égal à &ref=www%2Eatinternet%2Ecom et doit être le dernier paramètre")
    }
    
    // Teste le formattage de paramètres volatiles et persistents
    func testPreQueryWithPersistentAndVolatileParameters() {
        _ = [ATParam]()
        let pageParam = ATParam("p", value: {"home"}, type: .String)
        let valueStc = {ATTool.convertToString(["légume":["chou","patate","tomate","carotte"], "fruits": ["pomme", "abricot", "poire"]], separator: nil).value}
        let option = ATParamOption()
        option.encode = true
        let stcParam = ATParam("stc", value: valueStc, type: .String, options:option)
        
        let refParamOption = ATParamOption()
        refParamOption.relativePosition = .Last
        
        let refParam = ATParam("ref", value: {"www.atinternet.com?test1=1&test2=2&test3=<script></script>"}, type: .String, options: refParamOption)
        let valueDslu = {ATTool.convertToString(10, separator: nil).value}
        let dsluParam = ATParam("dslu", value: valueDslu, type: .Integer)
        let valueCrash = {ATTool.convertToString(false, separator: nil).value}
        let crashParam = ATParam("crash", value: valueCrash, type: .Bool)
        
        tracker.buffer.persistentParameters.addObject(pageParam)
        tracker.buffer.persistentParameters.addObject(stcParam)
        tracker.buffer.persistentParameters.addObject(refParam)
        tracker.buffer.volatileParameters.addObject(dsluParam)
        tracker.buffer.volatileParameters.addObject(crashParam)
        
        let volPar = tracker.buffer.volatileParameters as [AnyObject]
        let perPar = tracker.buffer.persistentParameters as [AnyObject]
        
        let builder = ATBuilder(tracker: self.tracker, volatileParameters: volPar, persistentParameters: perPar)
        
        var strings = builder.prepareQuery()
        
        XCTAssert(strings[14].str == "&p=home", "le premier paramètre doit être égal à &p=home")
        /*XCTAssert(strings[14].str == "&stc=%7B%22fruits%22%3A%5B%22pomme%22%2C%22abricot%22%2C%22poire%22%5D%2C%22l%C3%A9gume%22%3A%5B%22chou%22%2C%22patate%22%2C%22tomate%22%2C%22carotte%22%5D%7D", "le second paramètre doit être égal à &stc=chou%2Cpatate%2Ccarotte")*/
        XCTAssert(strings[16].str == "&dslu=10", "le paramètre dslu doit être égal à &dslu=10")
        XCTAssert(strings[17].str == "&crash=false", "le paramètre crash doit être égal à &crash=false")
        XCTAssert(strings[18].str == "&ref=www.atinternet.com?test1=1$test2=2$test3=script/script", "le paramètre ref doit être égal à &ref=www.atinternet.com et doit être le dernier paramètre")
    }
    
    func testOrganizeParameters() {
        _ = [ATParam]()
        
        let pageParam = ATParam("p", value: {"home"}, type: .String)
        
        let valueStc = {ATTool.convertToString(["légume":["chou","patate","tomate","carotte"], "fruits": ["pomme", "abricot", "poire"]], separator: nil).value}
        let stcParam = ATParam("stc", value: valueStc, type: .JSON)
        let valueArray = {ATTool.convertToString(["chou", "choux-fleur"], separator: nil).value}
        let arrayParam = ATParam("array", value: valueArray, type: .String)
        
        let refParamOptions = ATParamOption()
        refParamOptions.relativePosition = .Last
        
        let refParam = ATParam("ref", value: {"www.atinternet.com"}, type: .String, options: refParamOptions)
        let valueDslu = {ATTool.convertToString(10, separator: nil).value}
        let dsluParam = ATParam("dslu", value: valueDslu, type: .Integer)
        
        let crashParamOptions = ATParamOption()
        crashParamOptions.relativePosition = .After
        crashParamOptions.relativeParameterKey = "stc"
        
        let valueCrash = {ATTool.convertToString(false, separator: nil).value}
        let crashParam = ATParam("crash", value: valueCrash, type: .Bool, options: crashParamOptions)
        
        let hlParamOptions = ATParamOption()
        hlParamOptions.persistent = true
        let hlParam = ATParam("hl", value: {self.getDate()}, type: .String, options: hlParamOptions)
        
        tracker.buffer.volatileParameters.addObject(pageParam)
        tracker.buffer.volatileParameters.addObject(stcParam)
        tracker.buffer.volatileParameters.addObject(refParam)
        tracker.buffer.volatileParameters.addObject(dsluParam)
        tracker.buffer.volatileParameters.addObject(crashParam)
        tracker.buffer.persistentParameters.addObject(hlParam)
        tracker.buffer.volatileParameters.addObject(arrayParam)
        
        let volPar = tracker.buffer.volatileParameters as [AnyObject]
        let perPar = tracker.buffer.persistentParameters as [AnyObject]
        
        let builder = ATBuilder(tracker: self.tracker, volatileParameters: volPar, persistentParameters: perPar)
        
        let paramsConsolid = builder.volatileParameters + builder.persistentParameters
        let paramsNotOrganized = (paramsConsolid as NSArray).mutableCopy() as! NSMutableArray
        var params = builder.organizeParameters(paramsNotOrganized)
        
        XCTAssert(params[0].key == "p", "Le premier paramètre doit etre p=")
        XCTAssert(params[1].key == "stc", "Le second paramètre doit etre stc=")
        XCTAssert(params[2].key == "crash", "Le troisième paramètre doit etre crash=")
        XCTAssert(params[3].key == "dslu", "Le quatrième paramètre doit etre dslu=")
        XCTAssert(params[4].key == "array", "Le cinquième paramètre doit etre array=")
        XCTAssert(params[19].key == "hl", "Le sixième paramètre doit etre hl=")
        XCTAssert(params[20].key == "ref", "Le septième paramètre doit etre ref=")
    }
    
    /* Tests de la gestion du multihits */
    
    func testMultihitsSplitOnParameterWithoutError() {
        _ = [String]()
        
        for i in 1...60 {
            let value = {ATTool.convertToString("bigvalue\(i)", separator: nil).value}
            let param = ATParam("bigparameter\(i)", value: value, type: .String)
            tracker.buffer.volatileParameters.addObject(param)
        }
        
        let volPar = tracker.buffer.volatileParameters as [AnyObject]
        let perPar = tracker.buffer.persistentParameters as [AnyObject]
        
        let builder = ATBuilder(tracker: self.tracker, volatileParameters: volPar, persistentParameters: perPar)
        let hits = builder.build()
        
        var isErr = false
        for hit in hits {
            let rangeErr = hit.rangeOfString("mherr=1")
            if rangeErr.location != NSNotFound {
                isErr = true
                break
            }
        }
        
        XCTAssertTrue(hits.count > 1, "Le hit est trop long et devrait être découpé en plusieurs morceaux")
        XCTAssertFalse(isErr, "Un morceau de hit contient la variable d'erreur alors qu'il ne devrait pas")
    }
    
    func testMultihitsSplitOnValueWithoutError() {
        var array = [String]()
        
        for i in 1...150 {
            array.append("abigtestvalue\(i)")
        }
        
        let value = {ATTool.convertToString(array, separator: nil).value}
        let param = ATParam("ati", value: value, type: .String)
        tracker.buffer.volatileParameters.addObject(param)
        let volPar = tracker.buffer.volatileParameters as [AnyObject]
        let perPar = tracker.buffer.persistentParameters as [AnyObject]
        
        let builder = ATBuilder(tracker: self.tracker, volatileParameters: volPar, persistentParameters: perPar)
        let hits = builder.build()
        
        var isErr = false
        for hit in hits {
            let rangeErr = hit.rangeOfString("mherr=1")
            if rangeErr.location != NSNotFound {
                isErr = true
                break
            }
        }
        
        XCTAssertTrue(hits.count > 1, "Le hit est trop long et devrait être découpé en plusieurs morceaux")
        XCTAssertFalse(isErr, "Un morceau de hit contient la variable d'erreur alors qu'il ne devrait pas")
    }
    
    func testMultihitsSplitOnValueWithError() {
        var json = [String: String]()
        
        var val = "themegavalue30"
        for i in 1...60 {
            json["key\(i)"] = "value\(i)"
            if i == 30 {
                for _ in 1...10 {
                    val += val + "themegavalue30"
                }
            }
        }
        json["key30"] = val
        
        let value = {ATTool.convertToString(json, separator: nil).value}
        let param = ATParam("ati", value: value, type: .JSON)
        tracker.buffer.volatileParameters.addObject(param)
        let volPar = tracker.buffer.volatileParameters as [AnyObject]
        let perPar = tracker.buffer.persistentParameters as [AnyObject]
        
        let builder = ATBuilder(tracker: self.tracker, volatileParameters: volPar, persistentParameters: perPar)
        let hits = builder.build()
        
        var isErr = false
        for hit in hits {
            let rangeErr = hit.rangeOfString("mherr=1")
            if rangeErr.location == NSNotFound {
                isErr = true
                break
            }
        }
        
        XCTAssertTrue(hits.count > 1, "Le hit est trop long et devrait être découpé en plusieurs morceaux")
        XCTAssertTrue(isErr, "Aucun morceau de hit ne contient la variable d'erreur alors que cela devrait être le cas")
    }
    
    func testMultihitsSplitOnValueWithNotAllowedParam() {
        var array = [String]()
        
        for i in 1...150 {
            array.append("abigtestvalue\(i)")
        }
        
        let value = {ATTool.convertToString(array, separator: nil).value}
        let param = ATParam("var", value: value, type: .String)
        tracker.buffer.volatileParameters.addObject(param)
        let volPar = tracker.buffer.volatileParameters as [AnyObject]
        let perPar = tracker.buffer.persistentParameters as [AnyObject]
        
        let builder = ATBuilder(tracker: self.tracker, volatileParameters: volPar, persistentParameters: perPar)
        let hits = builder.build()
        
        var isErr = false
        for hit in hits {
            let rangeErr = hit.rangeOfString("mherr=1")
            if rangeErr.location != NSNotFound {
                isErr = true
                break
            }
        }
        
        XCTAssertTrue(hits.count == 1, "Le hit ne devrait pas être découpé")
        XCTAssertTrue(isErr, "Le hit ne contient pas la variable d'erreur alors que cela devrait être le cas")
    }

}
