//
//  ImageListViewModel.swift
//  PAF_Task
//
//  Created by Kruti on 17/04/24.
//

import Foundation

class ImageListViewModel {
    func getImageListData(_ limit: Int, completion: @escaping (_ success: Bool, _ results: [ImagesDetailListModel]?, _ error: String?) -> ()) {
        
        let urlStr = URLIdentifier.imageDetailURL + limit.description
        
        APIService.shared.fetchData(from: urlStr) { result in
            switch result {
            case .success(let data):
                DispatchQueue.main.async {
                    guard let responseData = data else {
                        completion(false, nil, "Error: Trying to parse Image data to model")
                        return
                    }
                    do {
                        let model = try JSONDecoder().decode([ImagesDetailListModel].self, from: responseData)
                        completion(true, model, nil)
                    } catch {
                        completion(false, nil, "Error: Trying to parse Image data to model")
                    }

               }
            case .failure(let failure):
                completion(false, nil, failure.localizedDescription)
            }
        }
        
    }
}
