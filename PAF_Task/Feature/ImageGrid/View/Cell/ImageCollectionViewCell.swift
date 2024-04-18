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
                self.imageView.image = self.centerCropImage(image: image, size: self.contentView.frame.size)
                //                self.imageView.image = self.cropImage(image, toRect: cropRect, viewWidth: self.contentView.frame.size.width, viewHeight: self.contentView.frame.size.height)
            }
        }
        task?.resume()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        task?.cancel()
    }
}

extension ImageCollectionViewCell {
    
    func cropImage(_ inputImage: UIImage, toRect cropRect: CGRect, viewWidth: CGFloat, viewHeight: CGFloat) -> UIImage?
    {
        let imageViewScale = max(inputImage.size.width / viewWidth,
                                 inputImage.size.height / viewHeight)
        
        let cropZone = CGRect(x:cropRect.origin.x * imageViewScale,
                              y:cropRect.origin.y * imageViewScale,
                              width:cropRect.size.width * imageViewScale,
                              height:cropRect.size.height * imageViewScale)
        
        
        guard let cutImageRef: CGImage = inputImage.cgImage?.cropping(to:cropZone)
        else {
            return nil
        }
        
        let croppedImage: UIImage = UIImage(cgImage: cutImageRef)
        return croppedImage
    }
    
    
    func centerCropImage(image: UIImage, size: CGSize) -> UIImage? {
        let cgImage = image.cgImage!
        
        let contextImage: UIImage = UIImage(cgImage: cgImage)
        
        let contextSize: CGSize = contextImage.size
        
        var posX: CGFloat = 0.0
        var posY: CGFloat = 0.0
        var width: CGFloat = size.width
        var height: CGFloat = size.height
        
        if contextSize.width > contextSize.height {
            posX = ((contextSize.width - contextSize.height) / 2)
            posY = 0
            width = contextSize.height
            height = contextSize.height
        } else {
            posX = 0
            posY = ((contextSize.height - contextSize.width) / 2)
            width = contextSize.width
            height = contextSize.width
        }
        
        let rect: CGRect = CGRect(x: posX, y: posY, width: width, height: height)
        
        let imageRef: CGImage = cgImage.cropping(to: rect)!
        
        let croppedImage: UIImage = UIImage(cgImage: imageRef, scale: image.scale, orientation: image.imageOrientation)
        
        return croppedImage
    }
}
