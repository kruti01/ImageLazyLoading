//
//  ImageCollectionViewCell.swift
//  PAF_Task
//
//  Created by Kruti on 17/04/24.
//

import UIKit

class ImageCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    
    var indexForImage = 0
    var imageURL: URL? {
        didSet {
            // Reset the image when a new URL is set
            imageView.image = UIImage(named: "defaultimage")
            
            // Load the image asynchronously
            loadImage()
        }
    }
    
    private var task: URLSessionDataTask?
    
    private func loadImage() {
        guard let url = imageURL else { return }
        
        if let cachedImage = ImageCache.shared.image(forKey: "index\(indexForImage)image.png") {
            imageView.image = cachedImage
            return
        }
        
        task = URLSession.shared.dataTask(with: url) { [weak self] (data, response, error) in
            guard let self = self else { return }
            
            if let error = error {
                DispatchQueue.main.async {
                    self.imageView.image = UIImage(named: "defaultimage")
                }
                print("Loading image: \(error.localizedDescription)")
                return
            }
            
            guard let data = data, let image = UIImage(data: data) else {
                DispatchQueue.main.async {
                    self.imageView.image = UIImage(named: "defaultimage")
                }
                print("Invalid image data")
                return
            }
            
            ImageCache.shared.save(image: image, forKey: "index\(self.indexForImage)image.png")
            
            DispatchQueue.main.async {
                self.imageView.image = image
            }
        }
        task?.resume()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        task?.cancel()
    }
}
