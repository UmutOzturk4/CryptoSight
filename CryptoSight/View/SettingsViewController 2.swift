//
//  SettingsViewController.swift
//  CryptoSight
//
//  Created by Umut Öztürk on 21.02.2025.
//

import UIKit
import SafariServices

class SettingsViewController: UIViewController {
    
    private let tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .insetGrouped)
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        table.translatesAutoresizingMaskIntoConstraints = false
        return table
    }()
    
    private enum Section: Int {
        case appearance
        case about
    }
    
    private let sections: [(Section, [String])] = [
        (.appearance, ["Dark Mode"]),
        (.about, ["Rate Us", "Privacy Policy"])
        
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    

    private func setupUI() {
        title = "Settings"
        view.backgroundColor = .systemBackground
        
        // Add tableView
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    private func handleDarkModeToggle(_ isOn: Bool) {
        // Save setting
        UserDefaults.standard.set(isOn, forKey: "isDarkMode")
        UserDefaults.standard.synchronize() // Force save immediately
        
        // Apply setting
        if let window = UIApplication.shared.windows.first {
            window.overrideUserInterfaceStyle = isOn ? .dark : .light
        }
    }
    
    private func openRateUs() {
        // Replace with your app ID
        let appId = "YOUR_APP_ID"
        guard let writeReviewURL = URL(string: "https://apps.apple.com/app/id\(appId)?action=write-review")
        else { return }
        
        UIApplication.shared.open(writeReviewURL, options: [:], completionHandler: nil)
    }
    
    private func openPrivacyPolicy() {
        guard let privacyURL = URL(string: "https://docs.google.com/document/d/1LoLyO0y5UyrNwlo6xhA05g-kvy1-xk53qOJCvb71j8c/edit?tab=t.0") else { return }
        let safariVC = SFSafariViewController(url: privacyURL)
        present(safariVC, animated: true)
    }
    
    private func navigateToConverter() {
        // Get reference to main storyboard
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        // Instantiate ConverterViewController from storyboard
        if let converterVC = storyboard.instantiateViewController(withIdentifier: "ConverterViewController") as? ConverterViewController {
            navigationController?.pushViewController(converterVC, animated: true)
        }
    }
}

extension SettingsViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].1.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch sections[section].0 {
        case .appearance:
            return "Appearance"
        case .about:
            return "About"
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let section = sections[indexPath.section]
        let row = section.1[indexPath.row]
        
        cell.textLabel?.text = row
        
        if row == "Dark Mode" {
            let switchView = UISwitch()
            // Default to light mode (false) if no setting exists
            let isDarkMode = UserDefaults.standard.bool(forKey: "isDarkMode")
            switchView.isOn = isDarkMode
            switchView.addTarget(self, action: #selector(darkModeChanged(_:)), for: .valueChanged)
            cell.accessoryView = switchView
            cell.selectionStyle = .none
        } else if section.0 == .about {
            cell.accessoryType = .disclosureIndicator
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let section = sections[indexPath.section]
        let row = section.1[indexPath.row]
        
        switch section.0 {
        case .about:
            if row == "Rate Us" {
                openRateUs()
            } else if row == "Privacy Policy" {
                openPrivacyPolicy()
            } else if row == "deneme" {
                navigateToConverter()
            }
        default:
            break
        }
    }
    
    @objc private func darkModeChanged(_ sender: UISwitch) {
        handleDarkModeToggle(sender.isOn)
    }
}
