import UIKit

final class RemoteImageView: UIImageView {
    
    private static let imageCache = NSCache<NSURL, UIImage>()
    private static let imageLoader = URLSession(configuration: .default)
    
    private var currentTask: URLSessionDataTask?
    private var currentURL: URL?
    
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
        currentTask?.cancel()
    }
    
    func setImage(urlString: String?, placeholder: UIImage? = nil) {
        image = placeholder
        currentTask?.cancel()
        currentTask = nil
        currentURL = nil
        
        guard let urlString,
              let url = URL(string: urlString) else {
            return
        }
        
        currentURL = url
        
        if let cachedImage = Self.imageCache.object(forKey: url as NSURL) {
            image = cachedImage
            return
        }
        
        currentTask = Self.imageLoader.dataTask(with: url) { [weak self] data, _, error in
            guard let self,
                  self.currentURL == url,
                  error == nil,
                  let data,
                  let image = UIImage(data: data) else {
                return
            }
            
            Self.imageCache.setObject(image, forKey: url as NSURL)
            DispatchQueue.main.async {
                guard self.currentURL == url else { return }
                self.image = image
            }
        }
        currentTask?.resume()
    }
}
