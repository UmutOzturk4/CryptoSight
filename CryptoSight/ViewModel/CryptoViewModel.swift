//
//  CryptoViewModel.swift
//  CryptoSight
//
//  Created by Umut Öztürk on 14.10.2024.
//

import Foundation
import RxSwift
import RxCocoa

class CryptoViewModel{
    
    let disposeBag = DisposeBag()
    let cryptoArray = [CryptoData]()
    let cryptos : PublishSubject<[CryptoData]> = PublishSubject()
    let error : PublishSubject<String> = PublishSubject()
    let loading : PublishSubject<Bool> = PublishSubject()
    let data : PublishSubject<String> = PublishSubject()
    let searchText = BehaviorSubject<String>(value: "")
    let showFavorites = BehaviorSubject<Bool>(value: false)
    private var favorites: [String] = [] // Store favorite coin IDs

    // Tüm kripto verileri
    private let allCryptos = BehaviorSubject<[CryptoData]>(value: [])
    
    // Filtrelenmiş veriler (TableView'e bind edilecek)
    let filteredCryptos = PublishSubject<[CryptoData]>()

    init() {
        // Load favorites from UserDefaults
        favorites = UserDefaults.standard.stringArray(forKey: "FavoriteCryptos") ?? []
        
        // Update filtered cryptos based on favorites selection and search text
        Observable.combineLatest(cryptos, searchText, showFavorites)
            .map { [weak self] cryptos, searchText, showFavorites in
                guard let self = self else { return [] }
                
                let searchFiltered = cryptos.filter { crypto in
                    if searchText.isEmpty { return true }
                    return crypto.name.lowercased().contains(searchText.lowercased()) ||
                           crypto.symbol.lowercased().contains(searchText.lowercased())
                }
                
                if showFavorites {
                    return searchFiltered.filter { self.favorites.contains(String($0.id)) }
                }
                return searchFiltered
            }
            .subscribe(onNext: { [weak self] filtered in
                self?.filteredCryptos.onNext(filtered)
            })
            .disposed(by: disposeBag)
    }
    
    func RequestData() {
        self.loading.onNext(true)
        
        let urlString = URL(string: "https://pro-api.coinmarketcap.com/v1/cryptocurrency/listings/latest?start=1&limit=1000&CMC_PRO_API_KEY=cb6c2d09-9ee7-4b0f-8c88-6ea976c9a899")
        
        WebService().DownloadCurrensies(url: urlString!) { [weak self] result in
            guard let self = self else { return }
            self.loading.onNext(false)
            
            switch result {
            case .success(let cryptos):
                self.allCryptos.onNext(cryptos)
                self.cryptos.onNext(cryptos)
            case .failure(let error):
                switch error {
                case .parsingError:
                    self.error.onNext("ParsingError \(error.localizedDescription)")
                case .serverError:
                    self.error.onNext("ServerError = \(error.localizedDescription)")
                }
            }
        }
    }
    
    
    func RequestCoinDetails(coin : CryptoData,completion : @escaping (Result<[String:Any],Error>) -> ()){
        
        let urlString = URL(string: "https://pro-api.coinmarketcap.com/v2/cryptocurrency/info?slug=\(coin.slug)&CMC_PRO_API_KEY=cb6c2d09-9ee7-4b0f-8c88-6ea976c9a899")
        
        URLSession.shared.dataTask(with: urlString!) { data, response, error in
            if error != nil {
                print(error?.localizedDescription,"deneme fail")
            } else if let data = data {
                do {
                    if let jsonResponse = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any] {
                        
                        if let jsonData = jsonResponse["data"] as? [String:Any] {
                            if let data = jsonData["\(coin.id)"] as? [String:Any] {
                                completion(.success(data))
                            } else {
                                completion(.failure(error!))
                            }
                        } else {
                            completion(.failure(error!))
                        }
                    } else {
                        completion(.failure(error!))
                    }
                    
                    
                    
                    
                    //print(jsonResponse)
                    
                } catch {
                    print(error)
                }
            } else {
                completion(.failure(error!))
            }
            
        }.resume()
        
    }
    
    // Add methods to manage favorites
    func toggleFavorite(for cryptoId: String) {
        if favorites.contains(cryptoId) {
            favorites.removeAll { $0 == cryptoId }
        } else {
            favorites.append(cryptoId)
        }
        
        // Save to UserDefaults
        UserDefaults.standard.set(favorites, forKey: "FavoriteCryptos")
        
        // Trigger update of filtered cryptos
        if let currentValue = try? showFavorites.value() {
            showFavorites.onNext(currentValue)
        }
    }
    
    func isFavorite(cryptoId: String) -> Bool {
        return favorites.contains(cryptoId)
    }
}
