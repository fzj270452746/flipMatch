
import UIKit

class HomeViewController: UIViewController {
    
    // MARK: - Device Adapter
    private let device_adapter = DeviceAdapter.shared
    
    // MARK: - UI Components
    private let background_image_view = UIImageView()
    private let overlay_view = UIView()
    private let title_label = UILabel()
    private let subtitle_label = UILabel()
    private let game_modes_stack_view = UIStackView()
    private let easy_mode_button = UIButton()
    private let normal_mode_button = UIButton()
    private let challenge_mode_button = UIButton()
    private let menu_stack_view = UIStackView()
    private let instructions_button = UIButton()
    private let records_button = UIButton()
    private let settings_button = UIButton()
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setup_ui()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    // MARK: - UI Setup
    private func setup_ui() {
        
        AudioManager.shared.play_background_music()

        setup_background()
        setup_overlay()
        setup_title()
        setup_game_modes()
        setup_menu()
        
        // 在所有视图都添加完成后设置约束
        setup_title_constraints()
        setup_game_modes_constraints()
        setup_menu_constraints()
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
        overlay_view.layer.cornerRadius = device_adapter.adaptive_corner_radius(base_radius: 20)
        overlay_view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(overlay_view)
        
        let margin = device_adapter.container_margin()
        NSLayoutConstraint.activate([
            overlay_view.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: margin),
            overlay_view.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: margin),
            overlay_view.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -margin),
            overlay_view.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -margin)
        ])
    }
    
    private func setup_title() {
        title_label.text = "Mahjong Flip Match"
        title_label.textColor = .white
        title_label.font = UIFont.systemFont(ofSize: 32, weight: .bold)
        title_label.textAlignment = .center
        title_label.translatesAutoresizingMaskIntoConstraints = false
        overlay_view.addSubview(title_label)
        
        subtitle_label.text = "Choose Your Challenge"
        subtitle_label.textColor = UIColor.white.withAlphaComponent(0.8)
        subtitle_label.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        subtitle_label.textAlignment = .center
        subtitle_label.translatesAutoresizingMaskIntoConstraints = false
        overlay_view.addSubview(subtitle_label)
    }
    
    private func setup_title_constraints() {
        NSLayoutConstraint.activate([
            title_label.topAnchor.constraint(equalTo: overlay_view.topAnchor, constant: 40),
            title_label.leadingAnchor.constraint(equalTo: overlay_view.leadingAnchor, constant: 20),
            title_label.trailingAnchor.constraint(equalTo: overlay_view.trailingAnchor, constant: -20),
            
            subtitle_label.topAnchor.constraint(equalTo: title_label.bottomAnchor, constant: 10),
            subtitle_label.leadingAnchor.constraint(equalTo: overlay_view.leadingAnchor, constant: 20),
            subtitle_label.trailingAnchor.constraint(equalTo: overlay_view.trailingAnchor, constant: -20)
        ])
    }
    
    private func setup_game_modes() {
        // Setup game modes stack view
        game_modes_stack_view.axis = .vertical
        game_modes_stack_view.spacing = device_adapter.adaptive_spacing(base_spacing: 15)
        game_modes_stack_view.distribution = .fillEqually
        game_modes_stack_view.translatesAutoresizingMaskIntoConstraints = false
        overlay_view.addSubview(game_modes_stack_view)
        
        // Configure game mode buttons
        configure_game_mode_button(easy_mode_button, title: "Easy Mode", subtitle: "24 cards", color: UIColor(red: 0.2, green: 0.8, blue: 0.4, alpha: 0.9))
        configure_game_mode_button(normal_mode_button, title: "Normal Mode", subtitle: "108 cards, full rules", color: UIColor(red: 0.2, green: 0.6, blue: 0.8, alpha: 0.9))
        configure_game_mode_button(challenge_mode_button, title: "Challenge Mode", subtitle: "108 cards, no hints", color: UIColor(red: 0.8, green: 0.2, blue: 0.2, alpha: 0.9))
        
        // Add to stack view
        game_modes_stack_view.addArrangedSubview(easy_mode_button)
        game_modes_stack_view.addArrangedSubview(normal_mode_button)
        game_modes_stack_view.addArrangedSubview(challenge_mode_button)
        
        // Add actions
        easy_mode_button.addTarget(self, action: #selector(start_easy_mode), for: .touchUpInside)
        normal_mode_button.addTarget(self, action: #selector(start_normal_mode), for: .touchUpInside)
        challenge_mode_button.addTarget(self, action: #selector(start_challenge_mode), for: .touchUpInside)
        
        // 确保按钮可以接收触摸事件
        easy_mode_button.isUserInteractionEnabled = true
        normal_mode_button.isUserInteractionEnabled = true
        challenge_mode_button.isUserInteractionEnabled = true
    }
    
    private func setup_game_modes_constraints() {
        // Layout constraints - 在视图都添加完成后设置约束
        let topMargin = device_adapter.adaptive_spacing(base_spacing: 40)
        let buttonHeight = device_adapter.adaptive_height(base_height: 70)
        
        NSLayoutConstraint.activate([
            game_modes_stack_view.topAnchor.constraint(equalTo: subtitle_label.bottomAnchor, constant: topMargin),
            game_modes_stack_view.leadingAnchor.constraint(equalTo: overlay_view.leadingAnchor, constant: 20),
            game_modes_stack_view.trailingAnchor.constraint(equalTo: overlay_view.trailingAnchor, constant: -20),
            easy_mode_button.heightAnchor.constraint(equalToConstant: buttonHeight),
            normal_mode_button.heightAnchor.constraint(equalToConstant: buttonHeight),
            challenge_mode_button.heightAnchor.constraint(equalToConstant: buttonHeight)
        ])
    }
    
    private func setup_menu() {
        // Setup menu stack view
        menu_stack_view.axis = .horizontal
        menu_stack_view.spacing = device_adapter.adaptive_spacing(base_spacing: 10)
        menu_stack_view.distribution = .fillEqually
        menu_stack_view.translatesAutoresizingMaskIntoConstraints = false
        overlay_view.addSubview(menu_stack_view)
        
        // Configure menu buttons
        configure_menu_button(instructions_button, title: "Instructions", icon: "📖")
        configure_menu_button(records_button, title: "Records", icon: "🏆")
        configure_menu_button(settings_button, title: "Settings", icon: "⚙️")
        
        // Add to stack view
        menu_stack_view.addArrangedSubview(instructions_button)
        menu_stack_view.addArrangedSubview(records_button)
        menu_stack_view.addArrangedSubview(settings_button)
        
        // Add actions
        instructions_button.addTarget(self, action: #selector(show_instructions), for: .touchUpInside)
        records_button.addTarget(self, action: #selector(show_records), for: .touchUpInside)
        settings_button.addTarget(self, action: #selector(show_settings), for: .touchUpInside)
        
        // 确保菜单按钮可以接收触摸事件
        instructions_button.isUserInteractionEnabled = true
        records_button.isUserInteractionEnabled = true
        settings_button.isUserInteractionEnabled = true
    }
    
    private func setup_menu_constraints() {
        // Layout constraints - 在视图都添加完成后设置约束
        let topMargin = device_adapter.adaptive_spacing(base_spacing: 30)
        let buttonHeight = device_adapter.adaptive_height(base_height: 50)
        
        NSLayoutConstraint.activate([
            menu_stack_view.topAnchor.constraint(equalTo: game_modes_stack_view.bottomAnchor, constant: topMargin),
            menu_stack_view.leadingAnchor.constraint(equalTo: overlay_view.leadingAnchor, constant: 20),
            menu_stack_view.trailingAnchor.constraint(equalTo: overlay_view.trailingAnchor, constant: -20),
            menu_stack_view.bottomAnchor.constraint(lessThanOrEqualTo: overlay_view.bottomAnchor, constant: -20),
            instructions_button.heightAnchor.constraint(equalToConstant: buttonHeight),
            records_button.heightAnchor.constraint(equalToConstant: buttonHeight),
            settings_button.heightAnchor.constraint(equalToConstant: buttonHeight)
        ])
    }
    
    private func configure_game_mode_button(_ button: UIButton, title: String, subtitle: String, color: UIColor) {
        button.backgroundColor = color
        button.layer.cornerRadius = device_adapter.adaptive_corner_radius(base_radius: 15)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isUserInteractionEnabled = true
        
        // Create title label
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.textColor = .white
        titleLabel.font = UIFont.systemFont(ofSize: device_adapter.adaptive_font_size(base_size: 22), weight: .bold)
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.isUserInteractionEnabled = false
        button.addSubview(titleLabel)
        
        // Create subtitle label
        let subtitleLabel = UILabel()
        subtitleLabel.text = subtitle
        subtitleLabel.textColor = UIColor.white.withAlphaComponent(0.8)
        subtitleLabel.font = UIFont.systemFont(ofSize: device_adapter.adaptive_font_size(base_size: 14), weight: .medium)
        subtitleLabel.textAlignment = .center
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.isUserInteractionEnabled = false
        button.addSubview(subtitleLabel)
        
        // Layout labels
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: button.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: button.centerYAnchor, constant: -8),
            titleLabel.leadingAnchor.constraint(greaterThanOrEqualTo: button.leadingAnchor, constant: 10),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: button.trailingAnchor, constant: -10),
            
            subtitleLabel.centerXAnchor.constraint(equalTo: button.centerXAnchor),
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            subtitleLabel.leadingAnchor.constraint(greaterThanOrEqualTo: button.leadingAnchor, constant: 10),
            subtitleLabel.trailingAnchor.constraint(lessThanOrEqualTo: button.trailingAnchor, constant: -10)
        ])
        
        // Add shadow
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 4)
        button.layer.shadowRadius = device_adapter.adaptive_corner_radius(base_radius: 5)
        button.layer.shadowOpacity = 0.5
        
        // Add animation for button press
        button.addTarget(self, action: #selector(button_pressed(_:)), for: .touchDown)
        button.addTarget(self, action: #selector(button_released(_:)), for: [.touchUpInside, .touchUpOutside])
    }
    
    private func configure_menu_button(_ button: UIButton, title: String, icon: String) {
        button.backgroundColor = UIColor(white: 0.2, alpha: 0.8)
        button.layer.cornerRadius = device_adapter.adaptive_corner_radius(base_radius: 10)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isUserInteractionEnabled = true
        
        // Create vertical stack view for icon and title
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 4
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.isUserInteractionEnabled = false
        button.addSubview(stackView)
        
        // Create icon label
        let iconLabel = UILabel()
        iconLabel.text = icon
        iconLabel.font = UIFont.systemFont(ofSize: 20)
        iconLabel.textAlignment = .center
        iconLabel.isUserInteractionEnabled = false
        stackView.addArrangedSubview(iconLabel)
        
        // Create title label
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.textColor = .white
        titleLabel.font = UIFont.systemFont(ofSize: device_adapter.adaptive_font_size(base_size: 12), weight: .medium)
        titleLabel.textAlignment = .center
        titleLabel.isUserInteractionEnabled = false
        stackView.addArrangedSubview(titleLabel)
        
        // Layout stack view
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: button.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: button.centerYAnchor),
            stackView.leadingAnchor.constraint(greaterThanOrEqualTo: button.leadingAnchor, constant: 5),
            stackView.trailingAnchor.constraint(lessThanOrEqualTo: button.trailingAnchor, constant: -5)
        ])
        
        // Add shadow
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.layer.shadowRadius = 3
        button.layer.shadowOpacity = 0.3
        
        // Add animation for button press
        button.addTarget(self, action: #selector(button_pressed(_:)), for: .touchDown)
        button.addTarget(self, action: #selector(button_released(_:)), for: [.touchUpInside, .touchUpOutside])
    }
    
    // MARK: - Button Animations
    @objc private func button_pressed(_ sender: UIButton) {
        UIView.animate(withDuration: 0.1) {
            sender.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
            sender.alpha = 0.9
        }
    }
    
    @objc private func button_released(_ sender: UIButton) {
        UIView.animate(withDuration: 0.1) {
            sender.transform = .identity
            sender.alpha = 1.0
        }
    }
    
    // MARK: - Button Actions
    @objc private func start_easy_mode() {
        let game_view_controller = GameViewController(game_mode: .easy)
        navigationController?.pushViewController(game_view_controller, animated: true)
    }
    
    @objc private func start_normal_mode() {
        let game_view_controller = GameViewController(game_mode: .normal)
        navigationController?.pushViewController(game_view_controller, animated: true)
    }
    
    @objc private func start_challenge_mode() {
        let game_view_controller = GameViewController(game_mode: .challenge)
        navigationController?.pushViewController(game_view_controller, animated: true)
    }
    
    @objc private func show_instructions() {
        let instructions_view_controller = InstructionsViewController()
        navigationController?.pushViewController(instructions_view_controller, animated: true)
    }
    
    @objc private func show_records() {
        let records_view_controller = RecordsViewController()
        navigationController?.pushViewController(records_view_controller, animated: true)
    }
    
    @objc private func show_settings() {
        let settings_view_controller = SettingsViewController()
        navigationController?.pushViewController(settings_view_controller, animated: true)
    }
}
