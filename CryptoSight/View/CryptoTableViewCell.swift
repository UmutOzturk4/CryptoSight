//
//  CryptoTableViewCell.swift
//  CryptoSight
//
//  Created by Umut Öztürk on 12.11.2024.
//

import UIKit
import SDWebImage

class CryptoTableViewCell: UITableViewCell {

    @IBOutlet weak var cryptoImageView: UIImageView!
    @IBOutlet weak var cryptoNameLabel: UILabel!
    @IBOutlet weak var cryptoPriceLabel: UILabel!
    
    // Add star imageView
    private lazy var starImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .systemYellow
        imageView.image = UIImage(systemName: "star.fill")
        imageView.isHidden = true // Hidden by default
        return imageView
    }()
    
    var selectedCoinSlug = String()
    var selectedCoinId = Int()
    var theUrl = String()
    var item: CryptoData?
    var onLongPress: ((CryptoData) -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Add star imageView to cell
        contentView.addSubview(starImageView)
        
        // Setup constraints for star
        NSLayoutConstraint.activate([
            starImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            starImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            starImageView.widthAnchor.constraint(equalToConstant: 20),
            starImageView.heightAnchor.constraint(equalToConstant: 20)
        ])
        
        // Add long press gesture
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
        longPress.minimumPressDuration = 2.0
        self.contentView.addGestureRecognizer(longPress)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
        
    }

    @objc private func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
        if gesture.state == .began, let crypto = item {
            onLongPress?(crypto)
        }
    }

    func updateFavoriteStatus(isFavorite: Bool) {
        // Show/hide star instead of changing background color
        starImageView.isHidden = !isFavorite
    }

    func configure(with crypto: CryptoData) {
        item = crypto
        cryptoNameLabel.text = crypto.name
        let price = String(format: "%.2f", crypto.quote.usd.price)
        cryptoPriceLabel.text = "\(price)$"
        selectedCoinSlug = crypto.slug
        selectedCoinId = crypto.id
        
        let baseUrl = "https://s2.coinmarketcap.com/static/img/coins/64x64/"
        let logoUrl = "\(baseUrl)\(crypto.id).png"
        cryptoImageView.sd_setImage(with: URL(string: logoUrl))
    }
}
