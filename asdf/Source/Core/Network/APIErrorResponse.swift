import Foundation

struct APIErrorResponse: Decodable {
    let message: String
    let statusCode: Int
    let errorType: String
    
    enum CodingKeys: String, CodingKey {
        case message
        case statusCode = "status_code"
        case errorType = "errorType"
    }
}
