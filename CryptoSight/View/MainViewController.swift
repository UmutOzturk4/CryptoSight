//
//  ViewController.swift
//  CryptoSight
//
//  Created by Umut Öztürk on 4.10.2024.
//

import UIKit
import RxSwift

class MainViewController: UIViewController,UITableViewDelegate,UISearchBarDelegate {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    static let shared = MainViewController()
    var cryptoList = [CryptoData]()
    var chosenCoin: CryptoData?
    let cryptoModel = CryptoViewModel()
    let disposeBag = DisposeBag()
    var searchText = String()
    var logoList = [String()]
    let group = DispatchGroup()
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    // Remove navigation bar segmented control
    private let segmentedControl: UISegmentedControl = {
        let items = ["Latest", "Favorites"]
        let control = UISegmentedControl(items: items)
        control.selectedSegmentIndex = 0
        control.translatesAutoresizingMaskIntoConstraints = false
        
        // Make the segmented control slightly smaller
        let fontSize = UIFont.systemFont(ofSize: 14)
        control.setTitleTextAttributes([.font: fontSize], for: .normal)
        
        // Add these lines to handle dark mode properly
        if #available(iOS 13.0, *) {
            control.backgroundColor = .systemBackground
            control.selectedSegmentTintColor = .systemBlue
        }
        
        return control
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Apply saved theme
        let isDarkMode = UserDefaults.standard.bool(forKey: "isDarkMode")
        UIApplication.shared.windows.forEach { window in
            window.overrideUserInterfaceStyle = isDarkMode ? .dark : .light
        }
        
        // Hide the navigation bar in this view
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        setupUI()
        tableView.rx.setDelegate(self).disposed(by: disposeBag)
        searchBar.delegate = self
        Bindings()
        cryptoModel.RequestData()
    }

    // Add this to show navigation bar when pushing to other views
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    private func setupUI() {
        // Add this to ensure the main view respects dark mode
        view.backgroundColor = .systemBackground
        
        // Add segmented control only
        view.addSubview(segmentedControl)
        
        NSLayoutConstraint.activate([
            segmentedControl.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 8),
            segmentedControl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            segmentedControl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            segmentedControl.heightAnchor.constraint(equalToConstant: 30),
            
            tableView.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor, constant: 8)
        ])
        
        // Add segmented control binding
        segmentedControl.rx.selectedSegmentIndex
            .subscribe(onNext: { [weak self] index in
                switch index {
                case 0: // Latest
                    self?.cryptoModel.showFavorites.onNext(false)
                case 1: // Favorites
                    self?.cryptoModel.showFavorites.onNext(true)
                default:
                    break
                }
            })
            .disposed(by: disposeBag)
    }


    

    private func Bindings() {
        
        cryptoModel.loading.bind(to:self.activityIndicator.rx.isAnimating).disposed(by: disposeBag)
        
        
        
        cryptoModel.error.observe(on: MainScheduler.asyncInstance).subscribe { error in
            print(error)
        }.disposed(by: disposeBag)
        
        cryptoModel.cryptos.observe(on: MainScheduler.asyncInstance).subscribe { cryptos in
            self.cryptoList = cryptos
            
        }.disposed(by: disposeBag)
        
        
        
        cryptoModel.filteredCryptos
            .observe(on: MainScheduler.asyncInstance)
            .bind(to: tableView.rx.items(cellIdentifier: "CryptoCell", cellType: CryptoTableViewCell.self)) { [weak self] row, item, cell in
                cell.configure(with: item)
                
                // Add long press handler
                cell.onLongPress = { [weak self] crypto in
                    self?.handleLongPress(for: crypto)
                }
                
                // Update favorite status
                let isFavorite = self?.cryptoModel.isFavorite(cryptoId: String(item.id)) ?? false
                cell.updateFavoriteStatus(isFavorite: isFavorite)
            }
            .disposed(by: disposeBag)

        
        searchBar.rx.text.orEmpty
            .distinctUntilChanged() // Aynı değeri tekrar göndermeyi önler
            .debounce(.milliseconds(100), scheduler: MainScheduler.instance) // Kullanıcının yazmayı durdurmasını bekler
            .debug()
            .bind(to: cryptoModel.searchText) // ViewModel'deki searchText'e bind edilir
            .disposed(by: disposeBag)
        
        searchBar.rx.cancelButtonClicked
            .subscribe(onNext: { [weak self] in
                self?.searchBar.text = ""
                self?.cryptoModel.searchText.onNext("")
                self!.view.endEditing(true)
            })
            .disposed(by: disposeBag)
        //push deneme

        searchBar.rx.textDidEndEditing
            .subscribe(onNext: { [weak self] in
                self?.searchBar.text = ""
                self?.cryptoModel.searchText.onNext("")
            })
            .disposed(by: disposeBag)
        
        tableView.rx.modelSelected(CryptoData.self)
            .subscribe(onNext: { [weak self] selectedCoin in
                guard let self = self else { return }
                
                chosenCoin = selectedCoin
                
                performSegue(withIdentifier: "toCoinDetailsSegue", sender: nil)
                
            })
            .disposed(by: disposeBag)

    }
    
    private func handleLongPress(for crypto: CryptoData) {
        let alert = UIAlertController(
            title: nil,
            message: nil,
            preferredStyle: .actionSheet
        )
        
        let isFavorite = cryptoModel.isFavorite(cryptoId: String(crypto.id))
        let favoriteAction = UIAlertAction(
            title: isFavorite ? "Remove from Favorites" : "Add to Favorites",
            style: .default
        ) { [weak self] _ in
            self?.cryptoModel.toggleFavorite(for: String(crypto.id))
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        alert.addAction(favoriteAction)
        alert.addAction(cancelAction)
        
        // For iPad
        if let popoverController = alert.popoverPresentationController {
            popoverController.sourceView = view
            popoverController.sourceRect = CGRect(x: view.bounds.midX, y: view.bounds.midY, width: 0, height: 0)
            popoverController.permittedArrowDirections = []
        }
        
        present(alert, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 84
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toCoinDetailsSegue" {
            let destination = segue.destination as! CoinDetailsViewController
            destination.selectedCoin = self.chosenCoin
        }
    }

    
}

