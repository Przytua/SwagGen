import Foundation
import JSONUtilities

public struct Discriminator {

    public var propertyName: String
    public let mapping: [String: Schema]
}

extension Discriminator: JSONObjectConvertible {

    public init(jsonDictionary: JSONDictionary) throws {
        propertyName = try jsonDictionary.json(atKeyPath: "propertyName")
        let mappingDictionary: [String: String] = try jsonDictionary.json(atKeyPath: "mapping")
        mapping = mappingDictionary.compactMapValues({ Schema(withSchemaReferenceName: $0) })
    }
}
