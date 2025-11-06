//
//  WebService.swift
//  CryptoSight
//
//  Created by Umut Öztürk on 4.10.2024.
//

import Foundation
import UIKit


enum CryptoError : Error {
    case serverError
    case parsingError
}


class WebService {
    

    func DownloadCurrensies(url : URL,completion : @escaping (Result<[CryptoData] ,CryptoError>) -> () ){
        URLSession.shared.dataTask(with: url) { data, response, error in
            if error != nil {
                completion(.failure(.serverError))
            } else if let data = data {
                
                do {
                    let jsonResponse = try JSONDecoder().decode(CryptoResponse.self, from: data)
                   
                    completion(.success(jsonResponse.data))
                    
                } catch {
                    do {
                        let decodedData = try JSONDecoder().decode(CryptoResponse.self, from: data)
                        print(decodedData)
                    } catch let DecodingError.dataCorrupted(context) {
                        print("corrupteddata = \(context)")
                    } catch let DecodingError.keyNotFound(key, context) {
                        print("Key '\(key)' not found:", context.debugDescription)
                    } catch let DecodingError.typeMismatch(type, context) {
                        print("Type '\(type)' mismatch:", context.debugDescription , context.codingPath)
                    } catch let DecodingError.valueNotFound(value, context) {
                        print("Value '\(value)' not found:", context.debugDescription)
                    } catch {
                        print("Error decoding JSON: \(error)")
                    }
                    print("hata = \(error.localizedDescription)")
                }
            }
        }.resume()
        
    }
    
    
}
