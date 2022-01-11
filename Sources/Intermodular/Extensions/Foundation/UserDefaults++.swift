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
            return try PropertyListDecoder().decode(Value.self, from: data, allowFragments: true)
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
            setValue(try PropertyListEncoder().encode(value, allowFragments: true), forKey: key)
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

extension PropertyListDecoder {
    private struct FragmentDecodingBox<T: Decodable>: Decodable {
        var value: T
        
        init(from decoder: Decoder) throws {
            let type = decoder.userInfo[.fragmentBoxedType] as! T.Type
            
            var container = try decoder.unkeyedContainer()
            
            self.value = try container.decode(type)
        }
    }
    
    public func decode<T: Decodable>(_ type: T.Type, from data: Data, allowFragments: Bool) throws -> T {
        guard allowFragments else {
            return try decode(type, from: data)
        }
        
        do {
            return try decode(type, from: data)
        } catch {
            if error.isPossibleFragmentDecodingError {
                let jsonObject = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
                let boxedData = try JSONSerialization.data(withJSONObject: [jsonObject])
                let decoder = copy()
                
                decoder.userInfo[CodingUserInfoKey.fragmentBoxedType] = type
                
                return try decoder
                    .decode(FragmentDecodingBox<T>.self, from: boxedData)
                    .value
            } else {
                throw error
            }
        }
    }
    
    private func copy() -> PropertyListDecoder {
        let decoder = PropertyListDecoder()

        decoder.userInfo = userInfo
        
        return decoder
    }
}

extension PropertyListEncoder {
    private struct FragmentEncodingBox<T: Encodable>: Encodable {
        var wrappedValue: T
        
        func encode(to encoder: Encoder) throws {
            var container = encoder.unkeyedContainer()
            
            try container.encode(wrappedValue)
        }
    }

    fileprivate func encode<T: Encodable>(_ value: T, allowFragments: Bool) throws -> Data {
        do {
            return try encode(value)
        } catch {
            if case let EncodingError.invalidValue(_, context) = error, context.debugDescription.lowercased().contains("fragment") {
                return try encode(FragmentEncodingBox(wrappedValue: value))
            } else {
                throw error
            }
        }
    }
}

fileprivate extension CodingUserInfoKey {
    static let fragmentBoxedType = CodingUserInfoKey(rawValue: "fragmentBoxedType")!
}

fileprivate extension Error {
    var isPossibleFragmentDecodingError: Bool {
        guard let error = self as? DecodingError else {
            return false
        }
        
        switch error {
            case let DecodingError.dataCorrupted(context):
                return true
                && context.debugDescription == "The given data was not valid JSON."
                && (context.underlyingError as NSError?)?
                    .debugDescription
                    .contains("option to allow fragments not set") ?? false
            case DecodingError.typeMismatch:
                return true
            default:
                return false
        }
    }
}
