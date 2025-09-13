

import UIKit

class InstructionsViewController: UIViewController {
    
    // MARK: - Device Adapter
    private let device_adapter = DeviceAdapter.shared
    
    // MARK: - UI Components
    private let background_image_view = UIImageView()
    private let overlay_view = UIView()
    private let scroll_view = UIScrollView()
    private let content_view = UIView()
    private let title_label = UILabel()
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setup_ui()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        navigationItem.title = "Game Instructions"
    }
    
    // MARK: - UI Setup
    private func setup_ui() {
        setup_background()
        setup_overlay()
        setup_scroll_view()
        setup_content()
    }
    
    private func setup_background() {
        view.backgroundColor = .black
        
        background_image_view.image = UIImage(named: "flipBackgroud")
        background_image_view.contentMode = .scaleAspectFill
        background_image_view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(background_image_view)
        
        NSLayoutConstraint.activate([
            background_image_view.topAnchor.constraint(equalTo: view.topAnchor),
            background_image_view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            background_image_view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            background_image_view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func setup_overlay() {
        overlay_view.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        overlay_view.layer.cornerRadius = 20
        overlay_view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(overlay_view)
        
        let margin: CGFloat = 15
        NSLayoutConstraint.activate([
            overlay_view.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: margin),
            overlay_view.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: margin),
            overlay_view.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -margin),
            overlay_view.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -margin)
        ])
    }
    
    private func setup_scroll_view() {
        scroll_view.translatesAutoresizingMaskIntoConstraints = false
        scroll_view.showsVerticalScrollIndicator = true
        scroll_view.showsHorizontalScrollIndicator = false
        scroll_view.alwaysBounceVertical = true
        scroll_view.indicatorStyle = .white
        overlay_view.addSubview(scroll_view)
        
        content_view.translatesAutoresizingMaskIntoConstraints = false
        scroll_view.addSubview(content_view)
        
        NSLayoutConstraint.activate([
            scroll_view.topAnchor.constraint(equalTo: overlay_view.topAnchor, constant: 10),
            scroll_view.leadingAnchor.constraint(equalTo: overlay_view.leadingAnchor, constant: 10),
            scroll_view.trailingAnchor.constraint(equalTo: overlay_view.trailingAnchor, constant: -10),
            scroll_view.bottomAnchor.constraint(equalTo: overlay_view.bottomAnchor, constant: -10),
            
            content_view.topAnchor.constraint(equalTo: scroll_view.topAnchor),
            content_view.leadingAnchor.constraint(equalTo: scroll_view.leadingAnchor),
            content_view.trailingAnchor.constraint(equalTo: scroll_view.trailingAnchor),
            content_view.bottomAnchor.constraint(equalTo: scroll_view.bottomAnchor),
            content_view.widthAnchor.constraint(equalTo: scroll_view.widthAnchor)
        ])
    }
    
    private func setup_content() {
        // Title
        title_label.text = "How to Play"
        title_label.textColor = .white
        title_label.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        title_label.textAlignment = .center
        title_label.translatesAutoresizingMaskIntoConstraints = false
        content_view.addSubview(title_label)
        
        // Game description sections - simplified for single screen
        let section_titles = ["How to Play", "Game Modes", "Matching Rules"]
        let section_contents = [
            "Tap tiles to flip them over. Find matching pairs and tap them to remove. Clear all tiles to win!",
            
            "• Easy: 24 cards, 5 hints, 5 shuffle\n• Normal: 108 cards, full rules, 3 hints, 3 shuffle\n• Challenge: 108 cards, no hints, 1 shuffle",
            
            "• Easy Mode: Match numbers only (any suit)\n• Normal/Challenge: Match both suit and number\n• Use hints and shuffles when stuck"
        ]
        
        var last_view: UIView = title_label
        
        // Add each section
        for i in 0..<section_titles.count {
            // 先添加到父视图，再创建约束
            let section_view = UIView()
            section_view.translatesAutoresizingMaskIntoConstraints = false
            content_view.addSubview(section_view)
            
            // 创建section内容
            let bottom_anchor = create_section(section_view: section_view, title: section_titles[i], content: section_contents[i])
            
            // 设置section_view的顶部约束
            NSLayoutConstraint.activate([
                section_view.topAnchor.constraint(equalTo: last_view.bottomAnchor, constant: 15),
                section_view.leadingAnchor.constraint(equalTo: content_view.leadingAnchor),
                section_view.trailingAnchor.constraint(equalTo: content_view.trailingAnchor)
            ])
            
            last_view = section_view
            
            // If this is the last section, constrain the bottom
            if i == section_titles.count - 1 {
                NSLayoutConstraint.activate([
                    section_view.bottomAnchor.constraint(equalTo: content_view.bottomAnchor, constant: -20)
                ])
            }
        }
        
        // Constrain title
        NSLayoutConstraint.activate([
            title_label.topAnchor.constraint(equalTo: content_view.topAnchor, constant: 20),
            title_label.leadingAnchor.constraint(equalTo: content_view.leadingAnchor),
            title_label.trailingAnchor.constraint(equalTo: content_view.trailingAnchor)
        ])
    }
    
    private func create_section(section_view: UIView, title: String, content: String) -> NSLayoutYAxisAnchor {
        // Section title
        let title_label = UILabel()
        title_label.text = title
        title_label.textColor = UIColor(red: 0.9, green: 0.7, blue: 0.3, alpha: 1.0) // Gold color
        title_label.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        title_label.translatesAutoresizingMaskIntoConstraints = false
        section_view.addSubview(title_label)
        
        // Section content
        let content_label = UILabel()
        content_label.text = content
        content_label.textColor = .white
        content_label.font = UIFont.systemFont(ofSize: 14)
        content_label.numberOfLines = 0
        content_label.translatesAutoresizingMaskIntoConstraints = false
        section_view.addSubview(content_label)
        
        // Divider
        let divider = UIView()
        divider.backgroundColor = UIColor.white.withAlphaComponent(0.3)
        divider.translatesAutoresizingMaskIntoConstraints = false
        section_view.addSubview(divider)
        
        NSLayoutConstraint.activate([
            title_label.topAnchor.constraint(equalTo: section_view.topAnchor),
            title_label.leadingAnchor.constraint(equalTo: section_view.leadingAnchor, constant: 10),
            title_label.trailingAnchor.constraint(equalTo: section_view.trailingAnchor, constant: -10),
            
            content_label.topAnchor.constraint(equalTo: title_label.bottomAnchor, constant: 5),
            content_label.leadingAnchor.constraint(equalTo: section_view.leadingAnchor, constant: 10),
            content_label.trailingAnchor.constraint(equalTo: section_view.trailingAnchor, constant: -10),
            
            divider.topAnchor.constraint(equalTo: content_label.bottomAnchor, constant: 8),
            divider.leadingAnchor.constraint(equalTo: section_view.leadingAnchor, constant: 5),
            divider.trailingAnchor.constraint(equalTo: section_view.trailingAnchor, constant: -5),
            divider.heightAnchor.constraint(equalToConstant: 1),
            divider.bottomAnchor.constraint(equalTo: section_view.bottomAnchor)
        ])
        
        return divider.bottomAnchor
    }
}
