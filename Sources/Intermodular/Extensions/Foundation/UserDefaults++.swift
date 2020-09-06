//
// Copyright (c) Vatsal Manot
//

import Foundation
import Swift

extension UserDefaults {
    public func decode<Value: Codable>(_ type: Value.Type = Value.self, forKey key: String) throws -> Value? {
        if type is URL.Type || type is Optional<URL>.Type {
            return try decode(String.self, forKey: key).flatMap(URL.init(string:)) as? Value
        } else if let value = value(forKey: key) as? Value {
            return value
        } else if let data = value(forKey: key) as? Data {
            return try PropertyListDecoder().decode(Value.self, from: data)
        } else {
            return nil
        }
    }
        
    public func encode<Value: Codable>(_ value: Value, forKey key: String) throws {
        if let value = value as? _opaque_Optional, !value.isNotNil {
            removeObject(forKey: key)
        } else if let value = value as? UserDefaultsPrimitve {
            setValue(value, forKey: key)
        } else if let value = value as? URL {
            setValue(value.path, forKey: key)
        } else {
            setValue(try PropertyListEncoder().encode(value), forKey: key)
        }
    }
}

// MARK: - Helpers-

private protocol _opaque_Optional {
    var isNotNil: Bool { get }
}

extension Optional: _opaque_Optional {
    var isNotNil: Bool {
        self != nil
    }
}

private protocol UserDefaultsPrimitve {

}

extension Bool: UserDefaultsPrimitve {
    
}

extension Double: UserDefaultsPrimitve {
    
}

extension Float: UserDefaultsPrimitve {
    
}

extension Int: UserDefaultsPrimitve {
    
}

extension Int8: UserDefaultsPrimitve {
    
}

extension Int16: UserDefaultsPrimitve {
    
}

extension Int32: UserDefaultsPrimitve {
    
}

extension Int64: UserDefaultsPrimitve {
    
}

extension String: UserDefaultsPrimitve {
    
}

extension UInt: UserDefaultsPrimitve {
    
}

extension UInt8: UserDefaultsPrimitve {
    
}

extension UInt16: UserDefaultsPrimitve {
    
}

extension UInt32: UserDefaultsPrimitve {
    
}

extension UInt64: UserDefaultsPrimitve {
    
}
