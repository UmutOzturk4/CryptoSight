//
//  WebService.swift
//  CryptoSight
//
//  Created by Umut Öztürk on 4.10.2024.
//

import Foundation


enum CryptoError : Error {
    case serverError
    case parsingError
}

class WebService {
    
    
    
    
    func DownloadCurrensies(url : URL,completion : @escaping (Result<[Crypto],CryptoError>) -> () ){
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if error != nil {
                completion(.failure(.serverError))
            } else if let data = data {
                let cryptoList = try? JSONDecoder().decode([Crypto].self,from: data)
                if let cryptoList = cryptoList {
                    completion(.success(cryptoList))
                } else {
                    completion(.failure(.parsingError))
                }
            }
        }.resume()
        
    }
    
    
}
