//
// Copyright (c) Vatsal Manot
//

import Foundation
import Swift

extension UserDefaults {
    public func decode<Value: Codable>(forKey key: String) throws -> Value? {
        if let value = value(forKey: key) as? Value {
            return value
        } else if let data = value(forKey: key) as? Data {
            return try PropertyListDecoder().decode(Value.self, from: data)
        } else {
            return nil
        }
    }
    
    public func decode<Value: Codable>(forKey key: String, defaultValue: Value) throws -> Value {
        try decode(forKey: key) ?? defaultValue
    }
    
    public func encode<Value: Codable>(_ value: Value, forKey key: String) throws {
        if value is UserDefaultsPrimitve {
            setValue(value, forKey: key)
        } else {
            setValue(try PropertyListEncoder().encode(value), forKey: key)
        }
    }
    
    public func encode<Value: Codable>(_ value: Value?, forKey key: String) throws {
        if let value = value {
            try encode(value, forKey: key)
        } else {
            removeObject(forKey: key)
        }
    }
}

// MARK: - Helpers-

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
