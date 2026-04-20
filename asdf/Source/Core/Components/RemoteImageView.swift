import UIKit
import Kingfisher

final class RemoteImageView: UIImageView {
    
    convenience init() {
        self.init(frame: .zero)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        clipsToBounds = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        cancelImageLoad()
    }
    
    func setImage(urlString: String?, placeholder: UIImage? = nil) {
        cancelImageLoad()
        image = placeholder
        
        guard let urlString,
              let url = URL(string: urlString) else {
            return
        }
        
        kf.setImage(with: url, placeholder: placeholder, options: [ .transition(.fade(0.2)), .cacheOriginalImage])
    }
    
    func cancelImageLoad() {
        kf.cancelDownloadTask()
    }
}
