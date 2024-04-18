//
//  ImageGridViewController.swift
//  PAF_Task
//
//  Created by Kruti on 15/04/24.
//

import UIKit
import Network

class ImageGridViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var viewNoInternet: UIView!
    
    private var imageDetailsArray: ImageDetails = []
    var limitCount = 100
    var loadMoreData = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setupViews()
        // Add observer in viewDidLoad or any appropriate method
        NotificationCenter.default.addObserver(self, selector: #selector(handleInternetConnectionStatusChanged(_:)), name: .InternetConnectionStatusChanged, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .InternetConnectionStatusChanged, object: nil)
    }
    
}

extension ImageGridViewController {
    @objc func handleInternetConnectionStatusChanged(_ notification: Notification) {
        if let isConnected = notification.userInfo?["isConnected"] as? Bool {
            DispatchQueue.main.async {
                if isConnected {
                    self.viewNoInternet.isHidden = true
                    if self.imageDetailsArray.count > 0 {
                        self.collectionView.reloadData()
                    } else {
                        self.apiCallToGetImageData(limitCount: self.limitCount)
                    }
                    // Internet connection available
                } else {
                        self.viewNoInternet.isHidden = false
                    // No internet connection
                }
            }
        }
    }

   
    private func setupViews() {
        applyStyle()
        setCollectionViewLayout()
        if InternetConnectionManager.shared.isConnectedToInternet {
            viewNoInternet.isHidden = true
            apiCallToGetImageData(limitCount: 100)
        } else {
            viewNoInternet.isHidden = false
        }
    }
    
    private func applyStyle() {
        viewNoInternet.isHidden = true
    }
    
    func setCollectionViewLayout() {
        collectionView.register(UINib(nibName: CellIdentifier.imageCell, bundle: nil), forCellWithReuseIdentifier: CellIdentifier.imageCell)
        
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.minimumLineSpacing = 5
        layout.minimumInteritemSpacing = 5
        let screenWidth = collectionView.frame.size.width
        let size = (screenWidth - 15) / 3 
        layout.itemSize =  CGSize(width: size, height: size)
        self.collectionView.collectionViewLayout = layout
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    func apiCallToGetImageData(limitCount: Int) {
        ImageListViewModel().getImageListData(limitCount) { success, results, error in
            if success {
                self.loadMoreData = true
                self.imageDetailsArray =  results ?? []
                if results?.count ?? 0 > 0 {
                    self.collectionView.reloadData()
                }
            } else {
                self.loadMoreData = false
                DispatchQueue.main.async {
                    self.showError(message: error?.description ?? "An error occurred while calling the API")
                }
            }
        }
    }
    
    func showError(message: String) {
            let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
        }
    
    func getImageURLStr(imageDetails: ImagesDetailListModel) -> String? {
        let thumbnail = imageDetails.thumbnail
        let domain = thumbnail?.domain ?? ""
        let basePath = thumbnail?.basePath ?? ""
        let key = thumbnail?.key?.rawValue ?? "image.jpg"
        let imageURLStr = domain + "/" + basePath + "/0/" + key
        return imageURLStr
    }
}

extension ImageGridViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
            if indexPath.item == imageDetailsArray.count - 1 && loadMoreData {
                // Load more data
                limitCount += 100
                apiCallToGetImageData(limitCount: limitCount)
            }
        }
}

extension ImageGridViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        imageDetailsArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: ImageCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: CellIdentifier.imageCell, for: indexPath) as! ImageCollectionViewCell
        let imageDetails = imageDetailsArray[indexPath.item]
        let imageURLStr = getImageURLStr(imageDetails: imageDetails)
        cell.indexForImage = indexPath.item
        cell.imageURL = URL(string: imageURLStr ?? "")
        return cell
    }
}


