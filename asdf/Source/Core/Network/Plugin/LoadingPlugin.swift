import Foundation
import Moya
import SVProgressHUD

final class LoadingPlugin: PluginType {
    
    func willSend(_ request: RequestType, target: TargetType) {
        guard let apiTarget = target as? APITargetType, apiTarget.shouldShowLoading else {
            return
        }
        
        DispatchQueue.main.async {
            SVProgressHUD.setDefaultMaskType(.clear)
            SVProgressHUD.show()
        }
    }
    
    func didReceive(_ result: Result<Response, MoyaError>, target: TargetType) {
        guard let apiTarget = target as? APITargetType, apiTarget.shouldShowLoading else {
            return
        }
        
        DispatchQueue.main.async {
            SVProgressHUD.dismiss()
        }
    }
}
