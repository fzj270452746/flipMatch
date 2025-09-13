

import UIKit

class SettingsViewController: UIViewController {
    
    // MARK: - Device Adapter
    private let device_adapter = DeviceAdapter.shared
    
    // MARK: - UI Components
    private let background_image_view = UIImageView()
    private let overlay_view = UIView()
    private let title_label = UILabel()
    private let settings_stack_view = UIStackView()
    
    // Sound settings
    private let sound_effects_label = UILabel()
    private let sound_effects_switch = UISwitch()
    private let sound_effects_container = UIView()
    
    // Music settings
    private let background_music_label = UILabel()
    private let background_music_switch = UISwitch()
    private let background_music_container = UIView()
    
    // Vibration settings
    private let vibration_label = UILabel()
    private let vibration_switch = UISwitch()
    private let vibration_container = UIView()
    
    // Theme settings
    private let theme_label = UILabel()
    private let theme_segment_control = UISegmentedControl(items: ["Classic", "Dark", "Light"])
    private let theme_container = UIView()
    
    // Reset button
    private let reset_button = UIButton()
    
    // MARK: - Properties
    private let user_defaults = UserDefaults.standard
    private let sound_effects_key = "sound_effects_enabled"
    private let background_music_key = "background_music_enabled"
    private let vibration_key = "vibration_enabled"
    private let theme_key = "app_theme"
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setup_ui()
        load_settings()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        navigationItem.title = "Settings"
    }
    
    // MARK: - UI Setup
    private func setup_ui() {
        setup_background()
        setup_overlay()
        setup_title_label()
        setup_settings_stack_view()
//        setup_sound_effects_setting()
        setup_background_music_setting()
//        setup_vibration_setting()
//        setup_theme_setting()
        setup_reset_button()
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
    
    private func setup_title_label() {
        title_label.text = "Game Settings"
        title_label.textColor = .white
        title_label.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        title_label.textAlignment = .center
        title_label.translatesAutoresizingMaskIntoConstraints = false
        overlay_view.addSubview(title_label)
        
        NSLayoutConstraint.activate([
            title_label.topAnchor.constraint(equalTo: overlay_view.topAnchor, constant: 20),
            title_label.leadingAnchor.constraint(equalTo: overlay_view.leadingAnchor, constant: 20),
            title_label.trailingAnchor.constraint(equalTo: overlay_view.trailingAnchor, constant: -20)
        ])
    }
    
    private func setup_settings_stack_view() {
        settings_stack_view.axis = .vertical
        settings_stack_view.distribution = .fillEqually
        settings_stack_view.spacing = 15
        settings_stack_view.translatesAutoresizingMaskIntoConstraints = false
        overlay_view.addSubview(settings_stack_view)
        
        NSLayoutConstraint.activate([
            settings_stack_view.topAnchor.constraint(equalTo: title_label.bottomAnchor, constant: 30),
            settings_stack_view.leadingAnchor.constraint(equalTo: overlay_view.leadingAnchor, constant: 20),
            settings_stack_view.trailingAnchor.constraint(equalTo: overlay_view.trailingAnchor, constant: -20)
        ])
    }
    
    private func setup_sound_effects_setting() {
        // Container
        sound_effects_container.backgroundColor = UIColor(white: 0.15, alpha: 0.5)
        sound_effects_container.layer.cornerRadius = 10
        sound_effects_container.translatesAutoresizingMaskIntoConstraints = false
        
        // Label
        sound_effects_label.text = "Sound Effects"
        sound_effects_label.textColor = .white
        sound_effects_label.font = UIFont.systemFont(ofSize: 18)
        sound_effects_label.translatesAutoresizingMaskIntoConstraints = false
        sound_effects_container.addSubview(sound_effects_label)
        
        // Switch
        sound_effects_switch.onTintColor = UIColor(red: 0.8, green: 0.2, blue: 0.2, alpha: 1.0)
        sound_effects_switch.translatesAutoresizingMaskIntoConstraints = false
        sound_effects_switch.addTarget(self, action: #selector(sound_effects_changed), for: .valueChanged)
        sound_effects_container.addSubview(sound_effects_switch)
        
        // Layout
        NSLayoutConstraint.activate([
            sound_effects_container.heightAnchor.constraint(equalToConstant: 60),
            
            sound_effects_label.leadingAnchor.constraint(equalTo: sound_effects_container.leadingAnchor, constant: 15),
            sound_effects_label.centerYAnchor.constraint(equalTo: sound_effects_container.centerYAnchor),
            
            sound_effects_switch.trailingAnchor.constraint(equalTo: sound_effects_container.trailingAnchor, constant: -15),
            sound_effects_switch.centerYAnchor.constraint(equalTo: sound_effects_container.centerYAnchor)
        ])
        
        settings_stack_view.addArrangedSubview(sound_effects_container)
    }
    
    private func setup_background_music_setting() {
        // Container
        background_music_container.backgroundColor = UIColor(white: 0.15, alpha: 0.5)
        background_music_container.layer.cornerRadius = 10
        background_music_container.translatesAutoresizingMaskIntoConstraints = false
        
        // Label
        background_music_label.text = "Background Music"
        background_music_label.textColor = .white
        background_music_label.font = UIFont.systemFont(ofSize: 18)
        background_music_label.translatesAutoresizingMaskIntoConstraints = false
        background_music_container.addSubview(background_music_label)
        
        // Switch
        background_music_switch.onTintColor = UIColor(red: 0.8, green: 0.2, blue: 0.2, alpha: 1.0)
        background_music_switch.translatesAutoresizingMaskIntoConstraints = false
        background_music_switch.addTarget(self, action: #selector(background_music_changed), for: .valueChanged)
        background_music_container.addSubview(background_music_switch)
        
        // Layout
        NSLayoutConstraint.activate([
            background_music_container.heightAnchor.constraint(equalToConstant: 60),
            
            background_music_label.leadingAnchor.constraint(equalTo: background_music_container.leadingAnchor, constant: 15),
            background_music_label.centerYAnchor.constraint(equalTo: background_music_container.centerYAnchor),
            
            background_music_switch.trailingAnchor.constraint(equalTo: background_music_container.trailingAnchor, constant: -15),
            background_music_switch.centerYAnchor.constraint(equalTo: background_music_container.centerYAnchor)
        ])
        
        settings_stack_view.addArrangedSubview(background_music_container)
    }
    
    private func setup_vibration_setting() {
        // Container
        vibration_container.backgroundColor = UIColor(white: 0.15, alpha: 0.5)
        vibration_container.layer.cornerRadius = 10
        vibration_container.translatesAutoresizingMaskIntoConstraints = false
        
        // Label
        vibration_label.text = "Vibration"
        vibration_label.textColor = .white
        vibration_label.font = UIFont.systemFont(ofSize: 18)
        vibration_label.translatesAutoresizingMaskIntoConstraints = false
        vibration_container.addSubview(vibration_label)
        
        // Switch
        vibration_switch.onTintColor = UIColor(red: 0.8, green: 0.2, blue: 0.2, alpha: 1.0)
        vibration_switch.translatesAutoresizingMaskIntoConstraints = false
        vibration_switch.addTarget(self, action: #selector(vibration_changed), for: .valueChanged)
        vibration_container.addSubview(vibration_switch)
        
        // Layout
        NSLayoutConstraint.activate([
            vibration_container.heightAnchor.constraint(equalToConstant: 60),
            
            vibration_label.leadingAnchor.constraint(equalTo: vibration_container.leadingAnchor, constant: 15),
            vibration_label.centerYAnchor.constraint(equalTo: vibration_container.centerYAnchor),
            
            vibration_switch.trailingAnchor.constraint(equalTo: vibration_container.trailingAnchor, constant: -15),
            vibration_switch.centerYAnchor.constraint(equalTo: vibration_container.centerYAnchor)
        ])
        
        settings_stack_view.addArrangedSubview(vibration_container)
    }
    
    private func setup_theme_setting() {
        // Container
        theme_container.backgroundColor = UIColor(white: 0.15, alpha: 0.5)
        theme_container.layer.cornerRadius = 10
        theme_container.translatesAutoresizingMaskIntoConstraints = false
        
        // Label
        theme_label.text = "Theme"
        theme_label.textColor = .white
        theme_label.font = UIFont.systemFont(ofSize: 18)
        theme_label.translatesAutoresizingMaskIntoConstraints = false
        theme_container.addSubview(theme_label)
        
        // Segment Control
        theme_segment_control.selectedSegmentIndex = 0
        theme_segment_control.backgroundColor = UIColor(white: 0.2, alpha: 0.7)
        theme_segment_control.selectedSegmentTintColor = UIColor(red: 0.8, green: 0.2, blue: 0.2, alpha: 0.8)
        theme_segment_control.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .normal)
        theme_segment_control.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
        theme_segment_control.translatesAutoresizingMaskIntoConstraints = false
        theme_segment_control.addTarget(self, action: #selector(theme_changed), for: .valueChanged)
        theme_container.addSubview(theme_segment_control)
        
        // Layout
        NSLayoutConstraint.activate([
            theme_container.heightAnchor.constraint(equalToConstant: 100),
            
            theme_label.topAnchor.constraint(equalTo: theme_container.topAnchor, constant: 15),
            theme_label.leadingAnchor.constraint(equalTo: theme_container.leadingAnchor, constant: 15),
            
            theme_segment_control.topAnchor.constraint(equalTo: theme_label.bottomAnchor, constant: 10),
            theme_segment_control.leadingAnchor.constraint(equalTo: theme_container.leadingAnchor, constant: 15),
            theme_segment_control.trailingAnchor.constraint(equalTo: theme_container.trailingAnchor, constant: -15),
            theme_segment_control.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        settings_stack_view.addArrangedSubview(theme_container)
    }
    
    private func setup_reset_button() {
        reset_button.setTitle("Reset All Settings", for: .normal)
        reset_button.setTitleColor(.white, for: .normal)
        reset_button.backgroundColor = UIColor(red: 0.8, green: 0.2, blue: 0.2, alpha: 0.8)
        reset_button.layer.cornerRadius = 15
        reset_button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        reset_button.translatesAutoresizingMaskIntoConstraints = false
        reset_button.addTarget(self, action: #selector(reset_settings), for: .touchUpInside)
        
        // Add shadow
        reset_button.layer.shadowColor = UIColor.black.cgColor
        reset_button.layer.shadowOffset = CGSize(width: 0, height: 2)
        reset_button.layer.shadowRadius = 3
        reset_button.layer.shadowOpacity = 0.5
        
        overlay_view.addSubview(reset_button)
        
        NSLayoutConstraint.activate([
            reset_button.topAnchor.constraint(equalTo: settings_stack_view.bottomAnchor, constant: 30),
            reset_button.centerXAnchor.constraint(equalTo: overlay_view.centerXAnchor),
            reset_button.widthAnchor.constraint(equalToConstant: 200),
            reset_button.heightAnchor.constraint(equalToConstant: 40),
            reset_button.bottomAnchor.constraint(lessThanOrEqualTo: overlay_view.bottomAnchor, constant: -20)
        ])
    }
    
    // MARK: - Settings Management
    private func load_settings() {
        // Load sound effects setting
        sound_effects_switch.isOn = user_defaults.bool(forKey: sound_effects_key, defaultValue: true)
        
        // Load background music setting
        background_music_switch.isOn = user_defaults.bool(forKey: background_music_key, defaultValue: true)
        
        // Load vibration setting
        vibration_switch.isOn = user_defaults.bool(forKey: vibration_key, defaultValue: true)
        
        // Load theme setting
        theme_segment_control.selectedSegmentIndex = user_defaults.integer(forKey: theme_key, defaultValue: 0)
    }
    
    private func save_setting(value: Any, forKey key: String) {
        user_defaults.set(value, forKey: key)
        user_defaults.synchronize()
        
        // Post notification for settings change
        NotificationCenter.default.post(name: NSNotification.Name("SettingsChanged"), object: nil)
    }
    
    // MARK: - Actions
    @objc private func sound_effects_changed() {
        save_setting(value: sound_effects_switch.isOn, forKey: sound_effects_key)
    }
    
    @objc private func background_music_changed() {
        save_setting(value: background_music_switch.isOn, forKey: background_music_key)
        
        // 根据开关状态控制背景音乐
        if background_music_switch.isOn {
            AudioManager.shared.resume_background_music()
        } else {
            AudioManager.shared.pause_background_music()
        }
    }
    
    @objc private func vibration_changed() {
        save_setting(value: vibration_switch.isOn, forKey: vibration_key)
    }
    
    @objc private func theme_changed() {
        save_setting(value: theme_segment_control.selectedSegmentIndex, forKey: theme_key)
    }
    
    @objc private func reset_settings() {
        let alert = UIAlertController(
            title: "Reset Settings",
            message: "Are you sure you want to reset all settings to default values?",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        alert.addAction(UIAlertAction(title: "Reset", style: .destructive) { [weak self] _ in
            guard let self = self else { return }
            
            // Reset to default values
            self.sound_effects_switch.isOn = true
            self.background_music_switch.isOn = true
            self.vibration_switch.isOn = true
            self.theme_segment_control.selectedSegmentIndex = 0
            
            // Save default values
            self.save_setting(value: true, forKey: self.sound_effects_key)
            self.save_setting(value: true, forKey: self.background_music_key)
            self.save_setting(value: true, forKey: self.vibration_key)
            self.save_setting(value: 0, forKey: self.theme_key)
            
            // Show confirmation
            self.show_toast(message: "Settings reset to default")
        })
        
        present(alert, animated: true)
    }
    
    private func show_toast(message: String) {
        let toast_label = UILabel()
        toast_label.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        toast_label.textColor = .white
        toast_label.textAlignment = .center
        toast_label.font = UIFont.systemFont(ofSize: 14)
        toast_label.text = message
        toast_label.alpha = 0
        toast_label.layer.cornerRadius = 10
        toast_label.clipsToBounds = true
        toast_label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(toast_label)
        
        NSLayoutConstraint.activate([
            toast_label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            toast_label.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            toast_label.widthAnchor.constraint(lessThanOrEqualToConstant: 280),
            toast_label.heightAnchor.constraint(equalToConstant: 35)
        ])
        
        UIView.animate(withDuration: 0.3, animations: {
            toast_label.alpha = 1
        }, completion: { _ in
            UIView.animate(withDuration: 0.3, delay: 2, options: [], animations: {
                toast_label.alpha = 0
            }, completion: { _ in
                toast_label.removeFromSuperview()
            })
        })
    }
}

// MARK: - UserDefaults Extension
// 注意：bool(forKey:defaultValue:)方法已在AudioManager.swift中定义
extension UserDefaults {
    func integer(forKey key: String, defaultValue: Int) -> Int {
        if object(forKey: key) == nil {
            return defaultValue
        }
        return integer(forKey: key)
    }
}
