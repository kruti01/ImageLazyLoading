//
//  APIServiceClass.swift
//  PAF_Task
//
//  Created by Kruti on 17/04/24.
//

import Foundation

enum APIError: Error {
    case invalidResponse
    case httpError(Int)
    case noData
    case serializationError(Error)
}

class APIService {
    static let shared = APIService()
    
    func fetchData(from urlString: String, completion: @escaping (Result<Data?, APIError>) -> Void) {
        let baseURLStr = URLIdentifier.baseURL
        guard let url = URL(string: baseURLStr + urlString) else { return }
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(.invalidResponse))
                return
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                completion(.failure(.httpError(httpResponse.statusCode)))
                return
            }
            
            guard let responseData = data else {
                completion(.failure(.noData))
                return
            }
            
            do {
                let json = try JSONSerialization.jsonObject(with: responseData, options: [])
                completion(.success(responseData))
            } catch {
                completion(.failure(.serializationError(error)))
            }
        }.resume()
    }
}
