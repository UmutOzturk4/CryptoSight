//
//  ConverterViewController.swift
//  CryptoSight
//
//  Created by Umut Öztürk on 27.02.2025.
//

import UIKit
import RxSwift

class ConverterViewController: UIViewController, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var selectCoinTxtField: UITextField!
    @IBOutlet weak var selectCoin2TxtField: UITextField!
    @IBOutlet weak var coinAmountTxtField: UITextField!
    @IBOutlet weak var coinAmount2TxtField: UITextField!
    
    var gradient: CAGradientLayer?

    
    private let cryptoModel = CryptoViewModel()
    private var filteredCoins: [CryptoData] = []
    private var allCoins: [CryptoData] = []
    private var selectedCoin1: CryptoData?
    private var selectedCoin2: CryptoData?
    private let disposeBag = DisposeBag()
    
    
    // Dropdown table view
    private lazy var dropdownTableView: UITableView = {
        let table = UITableView()
        table.delegate = self
        table.dataSource = self
        table.register(UITableViewCell.self, forCellReuseIdentifier: "CoinCell")
        table.isHidden = true
        table.layer.borderWidth = 1
        table.layer.borderColor = UIColor.lightGray.cgColor
        table.layer.cornerRadius = 8
        table.translatesAutoresizingMaskIntoConstraints = false
        return table
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        fetchCoins()
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(CloseKeyboard))
        view.addGestureRecognizer(gestureRecognizer)
        setupGradient(animated: false) // İlk yüklemede animasyon gerekmez

        
        
        // Add text field editing changed events
        selectCoinTxtField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        selectCoin2TxtField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        coinAmountTxtField.addTarget(self, action: #selector(amountTextFieldDidChange(_:)), for: .editingChanged)
        coinAmount2TxtField.addTarget(self, action: #selector(amountTextFieldDidChange(_:)), for: .editingChanged)
    }
    
    @objc func CloseKeyboard() {
        view.endEditing(true)
        print("başarı")
    }
    
    
    
    func setupGradient(animated: Bool = true) {
            // Dinamik sistem rengi
            let dynamicBackgroundColor = UIColor { trait in
                return trait.userInterfaceStyle == .dark ? .black : .white
            }

            let newColors: [CGColor] = [
                dynamicBackgroundColor.cgColor,
                dynamicBackgroundColor.cgColor,
                UIColor.systemPurple.withAlphaComponent(0.7).cgColor,
                UIColor.systemPurple.cgColor
            ]

            if let existingGradient = gradient {
                if animated {
                    let animation = CABasicAnimation(keyPath: "colors")
                    animation.fromValue = existingGradient.colors
                    animation.toValue = newColors
                    animation.duration = 0.5
                    existingGradient.add(animation, forKey: "colorChange")
                }
                existingGradient.colors = newColors
            } else {
                // Yeni gradient oluştur
                let gradientLayer = CAGradientLayer()
                gradientLayer.frame = view.bounds
                gradientLayer.colors = newColors
                gradientLayer.locations = [0.0, 0.5, 0.75, 1.0]
                gradientLayer.startPoint = CGPoint(x: 0, y: 0)
                gradientLayer.endPoint = CGPoint(x: 1, y: 1)

                view.layer.insertSublayer(gradientLayer, at: 0)
                self.gradient = gradientLayer
            }
        }

        // Tema değişiminde animasyonlu geçiş
        override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
            super.traitCollectionDidChange(previousTraitCollection)
            
            if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
                setupGradient(animated: true)
                
                // Update text field appearances
                let textFields = [selectCoinTxtField, selectCoin2TxtField, coinAmountTxtField, coinAmount2TxtField]
                textFields.forEach { textField in
                    if traitCollection.userInterfaceStyle == .dark {
                        textField?.backgroundColor = .white
                        textField?.textColor = .black
                        textField?.keyboardAppearance = .light
                        textField?.attributedPlaceholder = NSAttributedString(
                            string: textField?.placeholder ?? "",
                            attributes: [NSAttributedString.Key.foregroundColor: UIColor.gray]
                        )
                    } else {
                        textField?.backgroundColor = .black
                        textField?.textColor = .white
                        textField?.keyboardAppearance = .dark
                        textField?.attributedPlaceholder = NSAttributedString(
                            string: textField?.placeholder ?? "",
                            attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray]
                        )
                    }
                }
            }
        }
    
    private func setupUI() {
        // Setup text fields with opposite appearance
        let textFieldAppearance = { (textField: UITextField) in
            textField.delegate = self
            textField.borderStyle = .roundedRect
            textField.keyboardAppearance = self.traitCollection.userInterfaceStyle == .dark ? .light : .dark
            
            // Set background and text colors opposite to the current mode
            if self.traitCollection.userInterfaceStyle == .dark {
                textField.backgroundColor = .white
                textField.textColor = .black
                textField.attributedPlaceholder = NSAttributedString(
                    string: textField.placeholder ?? "",
                    attributes: [NSAttributedString.Key.foregroundColor: UIColor.gray]
                )
            } else {
                textField.backgroundColor = .black
                textField.textColor = .white
                textField.attributedPlaceholder = NSAttributedString(
                    string: textField.placeholder ?? "",
                    attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray]
                )
            }
        }
        
        // Apply to all text fields
        textFieldAppearance(selectCoinTxtField)
        textFieldAppearance(selectCoin2TxtField)
        textFieldAppearance(coinAmountTxtField)
        textFieldAppearance(coinAmount2TxtField)
        
        // Set placeholders
        selectCoinTxtField.placeholder = "Search or select a coin"
        selectCoin2TxtField.placeholder = "Search or select a coin"
        coinAmountTxtField.placeholder = "Amount"
        coinAmount2TxtField.placeholder = "Amount"
        
        // Set keyboard types
        coinAmountTxtField.keyboardType = .decimalPad
        coinAmount2TxtField.keyboardType = .decimalPad
        
        // Add dropdown table view
        view.addSubview(dropdownTableView)
        
        // Setup constraints
        NSLayoutConstraint.activate([
            dropdownTableView.topAnchor.constraint(equalTo: selectCoinTxtField.bottomAnchor, constant: 4),
            dropdownTableView.leadingAnchor.constraint(equalTo: selectCoinTxtField.leadingAnchor),
            dropdownTableView.trailingAnchor.constraint(equalTo: selectCoinTxtField.trailingAnchor),
            dropdownTableView.heightAnchor.constraint(equalToConstant: 200)
        ])
    }
    
    private func fetchCoins() {
        cryptoModel.RequestData()
        cryptoModel.cryptos
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] coins in
                self?.allCoins = coins
                self?.filteredCoins = coins
                DispatchQueue.main.async {
                    self?.dropdownTableView.reloadData()
                }
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: - UITextFieldDelegate
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == selectCoinTxtField || textField == selectCoin2TxtField {
            dropdownTableView.isHidden = false
        }
    }
    
    @objc private func textFieldDidChange(_ textField: UITextField) {
        if textField == selectCoinTxtField || textField == selectCoin2TxtField {
            filterCoins(with: textField.text ?? "")
        }
    }
    
    private func filterCoins(with searchText: String) {
        if searchText.isEmpty {
            filteredCoins = allCoins
        } else {
            filteredCoins = allCoins.filter { coin in
                coin.name.lowercased().contains(searchText.lowercased()) ||
                coin.symbol.lowercased().contains(searchText.lowercased())
            }
        }
        DispatchQueue.main.async {
            self.dropdownTableView.reloadData()
        }
    }
    
    // MARK: - UITableViewDelegate & DataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredCoins.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CoinCell", for: indexPath)
        let coin = filteredCoins[indexPath.row]
        cell.textLabel?.text = "\(coin.name) (\(coin.symbol))"
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedCoin = filteredCoins[indexPath.row]
        
        // Determine which text field is being edited
        if selectCoinTxtField.isFirstResponder {
            selectedCoin1 = selectedCoin
            selectCoinTxtField.text = selectedCoin.name
        } else if selectCoin2TxtField.isFirstResponder {
            selectedCoin2 = selectedCoin
            selectCoin2TxtField.text = selectedCoin.name
        }
        
        dropdownTableView.isHidden = true
        //textField.resignFirstResponder()
        
        // Perform conversion if both coins are selected
        if let _ = selectedCoin1, let _ = selectedCoin2 {
            performConversion()
        }
    }
    
    @objc private func amountTextFieldDidChange(_ textField: UITextField) {
        performConversion()
    }
    
    private func performConversion() {
        guard let coin1 = selectedCoin1,
              let coin2 = selectedCoin2 else { return }
        
        // Get the amount from the active text field
        if coinAmountTxtField.isFirstResponder {
            if let amount = Double(coinAmountTxtField.text ?? "0") {
                // Convert from coin1 to coin2
                let convertedAmount = (amount * coin1.quote.usd.price) / coin2.quote.usd.price
                coinAmount2TxtField.text = String(format: "%.8f", convertedAmount)
            }
        } else if coinAmount2TxtField.isFirstResponder {
            if let amount = Double(coinAmount2TxtField.text ?? "0") {
                // Convert from coin2 to coin1
                let convertedAmount = (amount * coin2.quote.usd.price) / coin1.quote.usd.price
                coinAmountTxtField.text = String(format: "%.8f", convertedAmount)
            }
        }
    }
    
    // Update text field validation
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == selectCoinTxtField || textField == selectCoin2TxtField {
            return true // Allow all characters for coin selection
        } else if textField == coinAmountTxtField || textField == coinAmount2TxtField {
            // Allow only numbers and decimal point
            let allowedCharacters = CharacterSet(charactersIn: "0123456789.")
            let characterSet = CharacterSet(charactersIn: string)
            return allowedCharacters.isSuperset(of: characterSet)
        }
        return true
    }
}
