import Foundation

struct UserModel: Codable {
    let data: UserData
}

struct UserData: Codable {
    let id: Int
    let userId: Int
    let responses: Responses
    
    enum CodingKeys: String, CodingKey {
        case id, userId, responses
    }
}

struct Responses: Codable {
    let id: String
    let preferredName: String
    let dob: String
    let doe: String
    let doi: String
    let kind: String
    let type: String
    let title: String
    let gender: String
    let issuer: String
    let status: String
    let userId: String
    let address: String
    
    enum CodingKeys: String, CodingKey {
        case id, preferredName, dob, doe, doi, kind, type, title, gender, issuer, status, userId, address
    }
}
