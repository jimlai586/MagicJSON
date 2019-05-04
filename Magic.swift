import Foundation

public protocol JSONKey {
    var jkey: String {get}
}

public protocol MJConvertible {
    var mj: MagicJSON {get}
}

extension Dictionary: MJConvertible where Key: JSONKey {
    public var mj: MagicJSON {
        return .dict(self.toStringKey())
    }
}

extension Dictionary where Key: JSONKey {
    func toStringKey() -> [String: Any] {
        var d = [String: Any]()
        for k in self.keys {
            let v = self[k]!
            if let u = v as? [Key: Any] {
                _ = u.toStringKey()
            }
            d[k.jkey] = v
        }
        return d
    }
}


typealias MJ = MagicJSON
public enum MagicJSON {
    case arr([Any]), dict([String: Any]), empty, null, raw(Any)
}

public extension MagicJSON {
    init(_ jd: Any?) {
        guard let jd = jd else {
            self = .null
            return
        }
        switch jd {
        case let u as [Any]:
            self = .arr(u)
        case let u as [String: Any]:
            self = .dict(u)
        case let u as MJConvertible:
            self = u.mj
        default:
            self = .raw(jd)
        }
    }
    
    init() {
        self = .empty
    }
    
    init(data: Data) {
        let json = try? JSONSerialization.jsonObject(with: data, options: [])
        self.init(json)
    }
    
    
    public subscript<T>(_ k: T) -> MagicJSON where T: JSONKey {
        get {
            switch self {
            case .dict(let d):
                return MagicJSON(d[k.jkey])
            default:
                return MagicJSON.null
            }
        }
        set {
            switch self {
            case .dict(var d):
                d[k.jkey] = newValue
                self = .dict(d)
            default:
                break
            }
        }
    }
    public subscript(_ idx: Int) -> MagicJSON {
        get {
            switch self {
            case .arr(let arr):
                guard 0 ..< arr.count ~= idx else {
                    return MagicJSON.null
                }
                return MagicJSON(arr[idx])
                
            default:
                return MagicJSON.null
            }
        }
        set {
            switch self {
            case .arr(var arr):
                guard 0 ..< arr.count ~= idx else {
                    return
                }
                arr[idx] = newValue
                self = .arr(arr)
            default:
                break
            }
        }
    }
    var stringValue: String {
        switch self {
        case .raw(let u):
            return String(describing: u)
        default:
            return ""
        }
    }
    var intValue: Int {
        switch self {
        case .raw(let u):
            return u as? Int ?? 0
        default:
            return 0
        }
    }
    var floatValue: Float {
        switch self {
        case .raw(let u):
            return u as? Float ?? 0
        default:
            return 0
        }
    }
    var doubleValue: Double {
        switch self {
        case .raw(let u):
            return u as? Double ?? 0
        default:
            return 0
        }
    }
    var string: String? {
        switch self {
        case .raw(let u):
            return String(describing: u)
        default:
            return nil
        }
    }
    var int: Int? {
        switch self {
        case .raw(let u):
            return u as? Int
        default:
            return nil
        }
    }
    var float: Float? {
        switch self {
        case .raw(let u):
            return u as? Float
        default:
            return nil
        }
    }
    var double: Double? {
        switch self {
        case .raw(let u):
            return u as? Double
        default:
            return nil
        }
    }
    var arrayValue: [MagicJSON] {
        switch self {
        case .arr(let u):
            return u.map {MagicJSON($0)}
        default:
            return []
        }
    }
    var dictValue: [String: MagicJSON] {
        switch self {
        case .dict(let u):
            return u.mapValues {MagicJSON($0)}
        default:
            return [:]
        }
    }
    var data: Data? {
        switch self {
        case .arr(let u):
            return try? JSONSerialization.data(withJSONObject: u, options: [.prettyPrinted])
        case .dict(let d):
            return try? JSONSerialization.data(withJSONObject: d, options: [.prettyPrinted])
        default:
            return nil
        }
    }
}

extension MagicJSON: CustomStringConvertible {
    public var description: String {
        var data: Data?
        switch self {
        case .arr(let u):
            data = try? JSONSerialization.data(withJSONObject: u, options: [.prettyPrinted])
        case .dict(let u):
            data = try? JSONSerialization.data(withJSONObject: u, options: [.prettyPrinted])
        case .empty:
            return "empty"
        case .null:
            return "null"
        case .raw(let u):
            return String(describing: u)
        }
        guard let d = data else {
            return "null"
        }
        return String(data: d, encoding: .utf8) ??  "null"
    }
}
