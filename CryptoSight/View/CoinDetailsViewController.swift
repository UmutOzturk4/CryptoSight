//
//  CoinDetailsViewController.swift
//  CryptoSight
//
//  Created by Umut Öztürk on 4.12.2024.
//

import UIKit
import SDWebImage

class CoinDetailsViewController: UIViewController {
    @IBOutlet weak var coinNameLabel: UILabel!
    @IBOutlet weak var coinImageView: UIImageView!
    @IBOutlet weak var coinPriceLabel: UILabel!
    
    let cryptoModel = CryptoViewModel()
    var CoinData = [String:Any]()
    @IBOutlet weak var coinWebsiteButton: UIButton!
    
    @IBOutlet weak var CoinDeatilsLabel: UILabel!
    var selectedCoin : CryptoData?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Make view respect system appearance
        view.backgroundColor = .systemBackground
        
        coinWebsiteButton.layer.cornerRadius = 20
        coinWebsiteButton.layer.masksToBounds = true
        
        let tableView = createCoinInfoTable()
                tableView.translatesAutoresizingMaskIntoConstraints = false
                view.addSubview(tableView)
                
                NSLayoutConstraint.activate([
                    tableView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                    tableView.topAnchor.constraint(equalTo: view.topAnchor, constant: coinPriceLabel.frame.maxY + 50),
                    tableView.widthAnchor.constraint(equalToConstant: 300)
                ])
    }
    
    override func viewDidLayoutSubviews() {
        super .viewDidLayoutSubviews()
        
        self.item = selectedCoin
        cryptoModel.RequestCoinDetails(coin: selectedCoin!) { result in
            
            switch result {
            case .success(let theData):
                self.CoinData = theData
                self.SetCoinDetail(coinDescription: theData["description"] as! String )
                
            case .failure(let error):
                print(error)
            }
            
            
        }
       
    }
    

    public var item : CryptoData! {
        didSet {
            
            coinNameLabel.text = item.name
            let baseUrl = "https://s2.coinmarketcap.com/static/img/coins/64x64/"
            let logoUrl = "\(baseUrl)\(item.id).png"
            coinImageView.sd_setImage(with: URL(string: logoUrl))
            
            
            
            let price = String(format: "%.2f",item.quote.usd.price)
            coinPriceLabel.text = "\(price)$  (\(String(format : "%.2f",item.quote.usd.percentChange24H))%)"
            
            if item.quote.usd.percentChange24H < 0.0 {
                coinPriceLabel.textColor = UIColor.red
            } else if item.quote.usd.percentChange24H > 0.0 {
                coinPriceLabel.textColor = UIColor.systemGreen
            }
            
        }
    }
    
    func SetCoinDetail(coinDescription : String){
        DispatchQueue.main.async {
            self.CoinDeatilsLabel.text = coinDescription
        }
        
    }
    @IBAction func OpenWebsite(_ sender: Any) {
            
        let websites = CoinData["urls"] as! [String : [String]]
        let coinWebsite = websites["website"]
        //print(coinWebsite?.first)
        
        if let website = coinWebsite?.first {
            do {
                try UIApplication.shared.open(URL(string: website)!)
            } catch {
                print("error link")
            }

        }
                    
        
        
       
                
    }
    
    func createCoinInfoTable() -> UIStackView {
            let stackView = UIStackView()
            stackView.axis = .vertical
            stackView.spacing = 10
            stackView.alignment = .fill
            stackView.distribution = .fillEqually
            
            let data: [(String, String)] = [
                ("Market Cap", "$900B"),
                ("24H Volume", "$46.65B"),
                ("Circulating Supply", "19,820,934 BTC"),
                ("24H Change", "-0.97%")
            ]
            
            for (title, value) in data {
                let row = createRow(title: title, value: value)
                stackView.addArrangedSubview(row)
            }
            
            return stackView
        }
        
        func createRow(title: String, value: String) -> UIStackView {
            let rowStack = UIStackView()
            rowStack.axis = .horizontal
            rowStack.spacing = 10
            rowStack.alignment = .center
            rowStack.distribution = .equalSpacing
            
            let titleLabel = UILabel()
            titleLabel.text = title
            titleLabel.font = UIFont.boldSystemFont(ofSize: 16)
            titleLabel.textColor = .label
            
            let valueLabel = UILabel()
            valueLabel.text = value
            valueLabel.font = UIFont.systemFont(ofSize: 16)
            valueLabel.textColor = .label
            
            rowStack.addArrangedSubview(titleLabel)
            rowStack.addArrangedSubview(valueLabel)
            
            return rowStack
        }
    
}
