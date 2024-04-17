//
//  ImageCatch.swift
//  PAF_Task
//
//  Created by Kruti on 17/04/24.
//

import Foundation
import UIKit

class ImageCache {
    static let shared = ImageCache()
    
    private let memoryCache = NSCache<NSString, UIImage>()
    private let diskCacheDirectory: URL
    
    private init() {
        let paths = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)
        diskCacheDirectory = paths[0].appendingPathComponent("ImageCache")
        
        if !FileManager.default.fileExists(atPath: diskCacheDirectory.path) {
            do {
                try FileManager.default.createDirectory(at: diskCacheDirectory, withIntermediateDirectories: true, attributes: nil)
            } catch {
                print("Error creating image cache directory: \(error.localizedDescription)")
            }
        }
    }
    
    func save(image: UIImage, forKey key: String) {
        memoryCache.setObject(image, forKey: key as NSString)
        
        let fileURL = diskCacheDirectory.appendingPathComponent(key)
        guard let data = image.jpegData(compressionQuality: 0.8) else {
            print("Error creating image data")
            return
        }
        
        do {
            try data.write(to: fileURL)
        } catch {
            print("Error saving image to disk cache: \(error.localizedDescription)")
        }
    }
    
    func image(forKey key: String) -> UIImage? {
        if let image = memoryCache.object(forKey: key as NSString) {
            return image
        }
        
        let fileURL = diskCacheDirectory.appendingPathComponent(key)
        if let data = try? Data(contentsOf: fileURL), let image = UIImage(data: data) {
            memoryCache.setObject(image, forKey: key as NSString)
            return image
        }
        
        return nil
    }
}
