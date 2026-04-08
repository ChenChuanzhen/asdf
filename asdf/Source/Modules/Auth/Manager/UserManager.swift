import Foundation

final class UserManager {
    
    static let shared = UserManager()
    
    private let userKey = "cached_user"
    
    private init() {}
    
    var currentUser: UserModel? {
        get {
            if let data = UserDefaults.standard.data(forKey: userKey) {
                do {
                    return try JSONDecoder().decode(UserModel.self, from: data)
                } catch {
                    print("❌ Failed to decode user from cache: \(error)")
                    return nil
                }
            }
            return nil
        }
        set {
            if let user = newValue {
                do {
                    let data = try JSONEncoder().encode(user)
                    UserDefaults.standard.set(data, forKey: userKey)
                    UserDefaults.standard.synchronize()
                    print("✅ User saved to cache: \(user.data.responses.preferredName)")
                } catch {
                    print("❌ Failed to encode user to cache: \(error)")
                }
            } else {
                UserDefaults.standard.removeObject(forKey: userKey)
                UserDefaults.standard.synchronize()
                print("❌ User removed from cache")
            }
        }
    }
    
    var isLoggedIn: Bool {
        return currentUser != nil
    }
    
    func saveUser(_ user: UserModel) {
        currentUser = user
    }
    
    func clearUser() {
        currentUser = nil
    }
}
