//
//  ViewController.swift
//  CryptoSight
//
//  Created by Umut Öztürk on 4.10.2024.
//

import UIKit
import RxSwift

class ViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    var cryptoList = [Crypto]()
    let cryptoModel = CryptoViewModel()
    let disposeBag = DisposeBag()
    var coinNameArray = [String]()
    var coinPriceArray = [Double]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        tableView.delegate = self
        tableView.dataSource = self
        
        //Bindings()
        //cryptoModel.RequestData()
        NewAPITest()
    }
    
    
    private func NewAPITest(){
        
        self.coinNameArray.removeAll(keepingCapacity: false)
        self.coinPriceArray.removeAll(keepingCapacity: false)
        
        var request = URLRequest(url: URL(string: "https://pro-api.coinmarketcap.com/v1/cryptocurrency/listings/latest?start=1&limit=100")!)
        request.addValue("cb6c2d09-9ee7-4b0f-8c88-6ea976c9a899", forHTTPHeaderField: "X-CMC_PRO_API_KEY")

        request.httpMethod = "GET"

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
          guard let data = data else {
  
            print(String(describing: error))
            return
          }
            do {
                if let jsonDictionary = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                               let dataArray = jsonDictionary["data"] as? [[String: Any]] {
                                
                                // Coin isimlerini ve fiyatlarını al
                                for coin in dataArray {
                                    guard let name = coin["name"] as? String else {
                                                            print("Coin adı alınamadı: \(coin)")
                                                            continue
                                                        }
                                                        
                                                        // USD fiyat bilgilerini al
                                                        guard let quote = coin["quote"] as? [String: Any],
                                                              let usd = quote["USD"] as? [String: Any],
                                                              let price = usd["price"] as? Double else {
                                                            print("Fiyat bilgileri alınamadı: \(coin)")
                                                            continue
                                                        }
                                                        
                                                        // Sonucu yazdır
                                                        print("Coin: \(name), Fiyat: \(price)")
                                    self.coinNameArray.append(name)
                                    self.coinPriceArray.append(price)
                                }
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                    
                            } else {
                                print("Veri sözlüğe dönüştürülemedi.")
                            }
            } catch {
              print("başarısız")
            }
            print("başarılı")
            
            //print(String(data: data,encoding: .utf8)!)
        }

        task.resume()
        
    }
    
    
    private func Bindings() {
        
        cryptoModel.error.observe(on: MainScheduler.asyncInstance).subscribe { error in
            print(error)
        }.disposed(by: disposeBag)
        
        cryptoModel.cryptos.observe(on: MainScheduler.asyncInstance).subscribe { cryptos in
            self.cryptoList = cryptos
            self.tableView.reloadData()
        }.disposed(by: disposeBag)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return coinNameArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        var content = cell.defaultContentConfiguration()
        content.text = coinNameArray[indexPath.row]
        content.secondaryText = String(coinPriceArray[indexPath.row])
        cell.contentConfiguration = content
        return cell
    }
    
}

