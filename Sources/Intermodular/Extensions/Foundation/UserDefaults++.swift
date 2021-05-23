//
// Copyright (c) Vatsal Manot
//

import Foundation
import Swift

extension UserDefaults {
    func decode<Value: Codable>(_ type: Value.Type = Value.self, forKey key: String) throws -> Value? {
        try decode(Value.self, from: object(forKey: key))
    }
    
    func decode<Value: Codable>(_ type: Value.Type, from object: Any?) throws -> Value? {
        guard let object = object else {
            return nil
        }
        
        if type is URL.Type || type is Optional<URL>.Type {
            return object as? Value
        } else if let value = object as? Value {
            return value
        } else if let data = object as? Data {
            return try PropertyListDecoder().decode(Value.self, from: data)
        } else {
            return nil
        }
    }

    func encode<Value: Codable>(_ value: Value, forKey key: String) throws {
        if let value = value as? _opaque_Optional, !value.isNotNil {
            removeObject(forKey: key)
        } else if let value = value as? UserDefaultsPrimitive {
            setValue(value, forKey: key)
        } else if let url = value as? URL {
            set(url, forKey: key)
        } else {
            setValue(try PropertyListEncoder().encode(value), forKey: key)
        }
    }
}

// MARK: - Auxiliary Implementation -

private protocol _opaque_Optional {
    var isNotNil: Bool { get }
}

extension Optional: _opaque_Optional {
    var isNotNil: Bool {
        self != nil
    }
}

fileprivate protocol UserDefaultsPrimitive {
    
}

extension Bool: UserDefaultsPrimitive {
    
}

extension Double: UserDefaultsPrimitive {
    
}

extension Float: UserDefaultsPrimitive {
    
}

extension Int: UserDefaultsPrimitive {
    
}

extension Int8: UserDefaultsPrimitive {
    
}

extension Int16: UserDefaultsPrimitive {
    
}

extension Int32: UserDefaultsPrimitive {
    
}

extension Int64: UserDefaultsPrimitive {
    
}

extension String: UserDefaultsPrimitive {
    
}

extension UInt: UserDefaultsPrimitive {
    
}

extension UInt8: UserDefaultsPrimitive {
    
}

extension UInt16: UserDefaultsPrimitive {
    
}

extension UInt32: UserDefaultsPrimitive {
    
}

extension UInt64: UserDefaultsPrimitive {
    
}
