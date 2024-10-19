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
    
    let cryptos : PublishSubject<[Crypto]> = PublishSubject()
    let error : PublishSubject<String> = PublishSubject()
    let loading : PublishSubject<Bool> = PublishSubject()
    
    func RequestData(){
        self.loading.onNext(true)
        let url = URL(string: "https://raw.githubusercontent.com/atilsamancioglu/K21-JSONDataSet/master/crypto.json")!
        WebService().DownloadCurrensies(url: url) { result in
            self.loading.onNext(false)
            switch result {
            case .success(let cryptos) :
                self.cryptos.onNext(cryptos)
            case .failure(let error):
                switch error {
                case .parsingError:
                    self.error.onNext("ParsingError")
                case .serverError:
                    self.error.onNext("ServerError")
                }
            }
            
        }
    }
    
}
