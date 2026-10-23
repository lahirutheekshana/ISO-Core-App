import SwiftUI

final class RecipeImageCache {
    static let shared = RecipeImageCache()
    private let cache = NSCache<NSURL, UIImage>()
    
    private init() {
        cache.countLimit = 200
    }
    
    func image(for url: URL) -> UIImage? {
        cache.object(forKey: url as NSURL)
    }
    
    func store(_ image: UIImage, for url: URL) {
        cache.setObject(image, forKey: url as NSURL)
    }
}

struct RecipeRemoteImage: View {
    let urlString: String
    
    @State private var loadedImage: UIImage?
    @State private var isLoading = false
    @State private var loadFailed = false
    @State private var reloadToken = 0
    
    private var imageURL: URL? {
        let trimmedURLString = urlString.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedURLString.isEmpty else { return nil }
        return URL(string: trimmedURLString)
    }
    
    var body: some View {
        Group {
            if let loadedImage {
                Image(uiImage: loadedImage)
                    .resizable()
                    .scaledToFill()
            } else if isLoading {
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .overlay(ProgressView())
            } else if loadFailed || imageURL == nil {
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .overlay(
                        Button {
                            reloadToken += 1
                        } label: {
                            Image(systemName: imageURL == nil ? "photo" : "arrow.clockwise")
                                .foregroundColor(.gray)
                        }
                        .buttonStyle(.plain)
                    )
            } else {
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .overlay(ProgressView())
            }
        }
        .task(id: "\(urlString)-\(reloadToken)") {
            await loadImage()
        }
    }
    
    @MainActor
    private func loadImage() async {
        guard let imageURL else {
            loadedImage = nil
            loadFailed = true
            isLoading = false
            return
        }
        
        if let cachedImage = RecipeImageCache.shared.image(for: imageURL) {
            loadedImage = cachedImage
            loadFailed = false
            isLoading = false
            return
        }
        
        isLoading = true
        loadFailed = false
        
        do {
            let (data, response) = try await URLSession.shared.data(from: imageURL)
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode),
                  let image = UIImage(data: data) else {
                loadedImage = nil
                loadFailed = true
                isLoading = false
                return
            }
            
            RecipeImageCache.shared.store(image, for: imageURL)
            loadedImage = image
            loadFailed = false
            isLoading = false
        } catch {
            loadedImage = nil
            loadFailed = true
            isLoading = false
        }
    }
}
