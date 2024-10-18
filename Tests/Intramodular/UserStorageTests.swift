//
// Copyright (c) Vatsal Manot
//

import SwiftUIX
import XCTest

final class UserStorageTests: XCTestCase {
    private func resetUserDefaults() {
        UserDefaults.standard.removeObject(forKey: "foo")
        UserDefaults.standard.removeObject(forKey: "bar")
        UserDefaults.standard.removeObject(forKey: "baz")
        UserDefaults.standard.synchronize()
    }
    
    func testSimpleValue() {
        resetUserDefaults()
        
        let testModel = TestObservableObject()
        let testModel2 = TestObservableObject()

        XCTAssertEqual(testModel.foo, 42)
        XCTAssertEqual(testModel2.foo, 42)

        UserDefaults.standard.setValue(69 as Int, forKey: "foo")
        
        XCTAssert(UserDefaults.standard.value(forKey: "foo") as! Int == 69)
        
        XCTAssertEqual(testModel.foo, 69)
        XCTAssertEqual(testModel2.foo, 69)

        testModel.foo = 4269
        
        XCTAssertEqual(UserDefaults.standard.value(forKey: "foo") as! Int, 4269)
        XCTAssertEqual(testModel2.foo, 4269)
        
        resetUserDefaults()
        
        XCTAssertEqual(testModel.foo, 42)
        XCTAssertEqual(testModel2.foo, 42)
    }
    
    func testComplexValue() {
        let testModel = TestObservableObject()
        let testModel2 = TestObservableObject()

        var newValue = TestObservableObject.Bar(x: 69, y: 69)
        
        testModel2.bar = newValue
                
        XCTAssertEqual(testModel2.bar, newValue)
        
        newValue = TestObservableObject.Bar(x: 42, y: 42)
        
        testModel2.bar = newValue
        
        XCTAssertEqual(testModel.bar, newValue)
        
        resetUserDefaults()
        
        XCTAssertEqual(testModel.bar, TestObservableObject.Bar())
        XCTAssertEqual(testModel2.bar, TestObservableObject.Bar())
    }
}

extension UserStorageTests {
    final class TestObservableObject: ObservableObject {
        @UserStorage("foo", store: .standard)
        var foo: Int = 42
        
        struct Bar: Codable, Hashable, Sendable {
            let x: Int
            let y: Int
            
            init(x: Int = 0, y: Int = 0) {
                self.x = x
                self.y = y
            }
        }
        
        @UserStorage("bar", store: .standard)
        var bar: Bar = Bar()
    }
}
