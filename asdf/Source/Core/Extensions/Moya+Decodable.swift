import Foundation
import Moya

extension Response {
    
    /// Map response to a Decodable type
    /// - Parameter type: The type to map to
    /// - Parameter decoder: JSONDecoder
    /// - Returns: Decoded object
    func map<T: Decodable>(_ type: T.Type, using decoder: JSONDecoder = JSONDecoder()) throws -> T {
        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw MoyaError.objectMapping(error, self)
        }
    }
}
