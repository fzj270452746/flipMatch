

import UIKit

class GameViewController: UIViewController {
    // MARK: - Device Adapter
    private let deviceAdapter = DeviceAdapter.shared
    
    // MARK: - Properties
    private let game_mode: GameMode
    private let game_manager = GameManager.shared
    private var card_views: [CardView] = []
    private var timer: Timer?
    private var elapsed_time: TimeInterval = 0
    
    // MARK: - UI Components
    private let background_image_view = UIImageView()
    private let overlay_view = UIView()
    private let game_board_view = UIView()
    private let info_panel = UIView()
    private let flip_count_label = UILabel()
    private let score_label = UILabel()
    private let pairs_label = UILabel()
    private let hint_button = UIButton()
    private let shuffle_button = UIButton()
    private let pause_button = UIButton()
    private let back_button = UIButton()
    
    // MARK: - Initialization
    init(game_mode: GameMode) {
        self.game_mode = game_mode
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        // 立即设置背景避免白屏
        view.backgroundColor = .black
        setup_ui()
        // 初始化游戏但不创建卡片视图
        initialize_game()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // 在布局完成后创建卡片视图
        if card_views.isEmpty {
            create_card_views()
            start_timer()
            update_ui()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // 隐藏导航栏，使用下方的返回按钮
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stop_timer()
    }
    
    // MARK: - UI Setup
    private func setup_ui() {
        setup_background()
        setup_overlay()
        setup_info_panel()
        setup_back_button() // 先设置返回按钮
        setup_game_board() // 再设置游戏板
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
    
    private func setup_info_panel() {
        info_panel.backgroundColor = UIColor(white: 0.1, alpha: 0.7)
        info_panel.layer.cornerRadius = 15
        info_panel.translatesAutoresizingMaskIntoConstraints = false
        overlay_view.addSubview(info_panel)
        
        // Setup labels
        flip_count_label.text = "Flips: 0"
        flip_count_label.textColor = .white
        flip_count_label.font = UIFont.monospacedDigitSystemFont(ofSize: 16, weight: .medium)
        flip_count_label.translatesAutoresizingMaskIntoConstraints = false
        info_panel.addSubview(flip_count_label)
        
        score_label.text = "Score: 0"
        score_label.textColor = .white
        score_label.font = UIFont.monospacedDigitSystemFont(ofSize: 16, weight: .medium)
        score_label.translatesAutoresizingMaskIntoConstraints = false
        info_panel.addSubview(score_label)
        
        pairs_label.text = "Pairs: 0/54"
        pairs_label.textColor = .white
        pairs_label.font = UIFont.monospacedDigitSystemFont(ofSize: 16, weight: .medium)
        pairs_label.translatesAutoresizingMaskIntoConstraints = false
        info_panel.addSubview(pairs_label)
        
        // Setup buttons
        configure_game_button(hint_button, title: "Hint (3)")
        hint_button.addTarget(self, action: #selector(use_hint), for: .touchUpInside)
        info_panel.addSubview(hint_button)
        
        configure_game_button(shuffle_button, title: "Shuffle (3)")
        shuffle_button.addTarget(self, action: #selector(shuffle_cards), for: .touchUpInside)
        info_panel.addSubview(shuffle_button)
        
        configure_game_button(pause_button, title: "Pause")
        pause_button.addTarget(self, action: #selector(toggle_pause), for: .touchUpInside)
        info_panel.addSubview(pause_button)
        
        // Hide hint button in challenge mode
        hint_button.isHidden = game_mode == .challenge
        
        // Layout
        NSLayoutConstraint.activate([
            info_panel.topAnchor.constraint(equalTo: overlay_view.topAnchor, constant: 10),
            info_panel.leadingAnchor.constraint(equalTo: overlay_view.leadingAnchor, constant: 10),
            info_panel.trailingAnchor.constraint(equalTo: overlay_view.trailingAnchor, constant: -10),
            info_panel.heightAnchor.constraint(equalToConstant: 100),
            
            flip_count_label.topAnchor.constraint(equalTo: info_panel.topAnchor, constant: 15),
            flip_count_label.leadingAnchor.constraint(equalTo: info_panel.leadingAnchor, constant: 20),
            
            score_label.topAnchor.constraint(equalTo: flip_count_label.topAnchor),
            score_label.centerXAnchor.constraint(equalTo: info_panel.centerXAnchor),
            
            pairs_label.topAnchor.constraint(equalTo: flip_count_label.topAnchor),
            pairs_label.trailingAnchor.constraint(equalTo: info_panel.trailingAnchor, constant: -20),
            
            hint_button.bottomAnchor.constraint(equalTo: info_panel.bottomAnchor, constant: -15),
            hint_button.leadingAnchor.constraint(equalTo: info_panel.leadingAnchor, constant: 20),
            hint_button.widthAnchor.constraint(equalToConstant: 90),
            hint_button.heightAnchor.constraint(equalToConstant: 30),
            
            shuffle_button.bottomAnchor.constraint(equalTo: hint_button.bottomAnchor),
            shuffle_button.centerXAnchor.constraint(equalTo: info_panel.centerXAnchor),
            shuffle_button.widthAnchor.constraint(equalTo: hint_button.widthAnchor),
            shuffle_button.heightAnchor.constraint(equalTo: hint_button.heightAnchor),
            
            pause_button.bottomAnchor.constraint(equalTo: hint_button.bottomAnchor),
            pause_button.trailingAnchor.constraint(equalTo: info_panel.trailingAnchor, constant: -20),
            pause_button.widthAnchor.constraint(equalTo: hint_button.widthAnchor),
            pause_button.heightAnchor.constraint(equalTo: hint_button.heightAnchor)
        ])
    }
    
    private func configure_game_button(_ button: UIButton, title: String) {
        button.setTitle(title, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor(red: 0.7, green: 0.2, blue: 0.2, alpha: 0.8)
        button.layer.cornerRadius = 10
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        // Add shadow
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.layer.shadowRadius = 3
        button.layer.shadowOpacity = 0.5
        
        // Add animation for button press
        button.addTarget(self, action: #selector(button_pressed(_:)), for: .touchDown)
        button.addTarget(self, action: #selector(button_released(_:)), for: [.touchUpInside, .touchUpOutside])
    }
    
    private func setup_game_board() {
        game_board_view.backgroundColor = .clear
        game_board_view.translatesAutoresizingMaskIntoConstraints = false
        overlay_view.addSubview(game_board_view)
        
        let margin = deviceAdapter.adaptive_spacing(base_spacing: 5) // 减少边距
        let top_margin: CGFloat = 0 // 完全移除顶部间距
        
        NSLayoutConstraint.activate([
            game_board_view.topAnchor.constraint(equalTo: info_panel.bottomAnchor, constant: top_margin),
            game_board_view.leadingAnchor.constraint(equalTo: overlay_view.leadingAnchor, constant: margin),
            game_board_view.trailingAnchor.constraint(equalTo: overlay_view.trailingAnchor, constant: -margin),
            game_board_view.bottomAnchor.constraint(equalTo: back_button.topAnchor, constant: -margin)
        ])
    }
    
    private func setup_back_button() {
        back_button.setTitle("Back To Menu", for: .normal)
        back_button.setTitleColor(.white, for: .normal)
        back_button.backgroundColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 0.8)
        back_button.layer.cornerRadius = 8
        back_button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        back_button.translatesAutoresizingMaskIntoConstraints = false
        overlay_view.addSubview(back_button)
        
        // 添加按钮点击事件
        back_button.addTarget(self, action: #selector(back_to_home), for: .touchUpInside)
        
        // 设置约束
        NSLayoutConstraint.activate([
            back_button.leadingAnchor.constraint(equalTo: overlay_view.leadingAnchor, constant: 20),
            back_button.trailingAnchor.constraint(equalTo: overlay_view.trailingAnchor, constant: -20),
            back_button.bottomAnchor.constraint(equalTo: overlay_view.bottomAnchor, constant: -20),
            back_button.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    // MARK: - Helper Methods
    private func get_grid_dimensions() -> (rows: Int, columns: Int) {
        switch game_mode {
        case .easy:
            return (4, 6) // 24 cards = 4x6 (横6竖4)
        case .normal, .challenge:
            return (9, 12) // 108 cards = 9x12
        }
    }
    
    // MARK: - Game Setup
    private func initialize_game() {
        // Start the game
        game_manager.start_game(mode: game_mode)
        
        // Set up callbacks
        game_manager.on_match = { [weak self] card1, card2 in
            self?.handle_match(card1, card2)
        }
        
        game_manager.on_mismatch = { [weak self] card1, card2 in
            self?.handle_mismatch(card1, card2)
        }
        
        game_manager.on_game_complete = { [weak self] time, score in
            self?.handle_game_complete(time: time, score: score)
        }
        
        game_manager.on_hint_used = { [weak self] card1, card2 in
            self?.highlight_cards(card1, card2)
        }
        
        game_manager.on_shuffle = { [weak self] in
            self?.update_card_views()
        }
    }
    
    // 此方法已不再直接调用，功能已分散到viewDidLayoutSubviews中
    private func setup_game() {
        initialize_game()
        create_card_views()
        start_timer()
        update_ui()
    }
    
    private func create_card_views() {
        // Clear existing card views
        for view in card_views {
            view.removeFromSuperview()
        }
        card_views = []
        
        // Get grid dimensions based on game mode
        let (rows, columns) = get_grid_dimensions()
        
        // Use DeviceAdapter to calculate card size and layout
        let grid_size = CGSize(width: CGFloat(columns), height: CGFloat(rows))
        let spacing = deviceAdapter.adaptive_spacing(base_spacing: 2)
        
        // 确保我们有有效的尺寸来计算卡片大小
        var available_width = game_board_view.bounds.width
        var available_height = game_board_view.bounds.height
        
        // 如果bounds尚未设置（宽度或高度为0），则使用frame
        if available_width <= 0 || available_height <= 0 {
            available_width = game_board_view.frame.width
            available_height = game_board_view.frame.height
            
            // 如果frame也为0，则使用父视图尺寸减去边距
            if available_width <= 0 || available_height <= 0, let parent = game_board_view.superview {
                let margin = deviceAdapter.adaptive_spacing(base_spacing: 10)
                available_width = parent.bounds.width - (margin * 2)
                available_height = parent.bounds.height - (margin * 2) - 100 // 减去info_panel的高度
                
            }
        }
        
        
        // 确保我们有有效的尺寸
        guard available_width > 0, available_height > 0 else {
            return
        }
        
        let card_width = (available_width - CGFloat(columns - 1) * spacing) / CGFloat(columns)
        let card_height = (available_height - CGFloat(rows - 1) * spacing) / CGFloat(rows)
        
        // 麻将牌应该是长方形，宽度比高度小，进一步减少高度以贴近麻将贴图
        let mahjong_width = min(card_width, card_height * 0.75) // 宽度是高度的75%
        let mahjong_height = min(card_height * 0.7, card_width / 0.75) // 高度减少30%，宽度是高度的1.33倍
        let card_size = CGSize(width: mahjong_width, height: mahjong_height)
        
        // 根据游戏模式调整麻将牌大小，减少空白边
        let final_card_size: CGSize
        if game_mode == .easy {
            // 简单模式：使用更小的麻将牌，确保6x4布局适合屏幕，不留空白边
            let max_width = available_width * 0.95 / CGFloat(columns)
            let max_height = available_height * 0.95 / CGFloat(rows)
            let easy_width = min(mahjong_width, max_width)
            let easy_height = min(mahjong_height, max_height)
            final_card_size = CGSize(width: easy_width, height: easy_height)
        } else {
            // 普通模式和挑战模式：调整麻将牌高度，减少上下空白，不留空白边
            let adjusted_height = min(mahjong_height, available_height * 0.95 / CGFloat(rows))
            final_card_size = CGSize(width: mahjong_width, height: adjusted_height)
        }
        
        
        // Calculate total width and height of the grid
        let total_width = final_card_size.width * CGFloat(columns) + CGFloat(columns - 1) * spacing
        let total_height = final_card_size.height * CGFloat(rows) + CGFloat(rows - 1) * spacing
        
        // Calculate starting position to center the grid
        let start_x = (available_width - total_width) / 2
        let start_y = (available_height - total_height) / 2
        
        // Create card views
        for i in 0..<game_manager.cards.count {
            let row = i / columns
            let column = i % columns
            
            let x = start_x + CGFloat(column) * (final_card_size.width + spacing)
            let y = start_y + CGFloat(row) * (final_card_size.height + spacing)
            
            let card = game_manager.cards[i]
            let card_view = CardView(frame: CGRect(x: x, y: y, width: final_card_size.width, height: final_card_size.height), card: card)
            card_view.delegate = self
            
            // Apply device-specific adaptations
            card_view.layer.cornerRadius = deviceAdapter.adaptive_corner_radius(base_radius: 5)
            
            // 如果卡片已经翻开，直接显示前面
            if card.is_flipped {
                card_view.is_flipped = true
                card_view.front_view.isHidden = false
                card_view.back_view.isHidden = true
            }
            
            game_board_view.addSubview(card_view)
            card_views.append(card_view)
        }
    }
    
    // MARK: - Game Actions
    @objc private func use_hint() {
        if let pair = game_manager.use_hint() {
            update_ui()
        }
    }
    
    @objc private func shuffle_cards() {
        game_manager.shuffle_cards()
        update_ui()
    }
    
    @objc private func toggle_pause() {
        if game_manager.is_game_paused {
            game_manager.resume_game()
            start_timer()
            pause_button.setTitle("Pause", for: .normal)
        } else {
            game_manager.pause_game()
            stop_timer()
            pause_button.setTitle("Resume", for: .normal)
            show_pause_overlay()
        }
    }
    
    @objc private func back_to_home() {
        // Show confirmation alert
        let alert = UIAlertController(title: "Quit Game", message: "Are you sure you want to quit? Your progress will be lost.", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        alert.addAction(UIAlertAction(title: "Quit", style: .destructive) { [weak self] _ in
            self?.navigationController?.popViewController(animated: true)
        })
        
        present(alert, animated: true)
    }
    
    // MARK: - Game Event Handlers
    private func handle_match(_ card1: Card, _ card2: Card) {
        // Update UI
        update_ui()
        
        // 显示匹配成功的小庆祝效果
        show_celebration_effect()
        
        // Animate matched cards with elimination effect
        for card_view in card_views {
            if card_view.card.id == card1.id || card_view.card.id == card2.id {
                card_view.animate_elimination()
            }
        }
        
        // Check if there are possible moves
        if !game_manager.check_for_possible_moves() && game_manager.matched_pairs < game_manager.total_pairs {
            handle_no_moves()
        }
    }
    
    private func handle_mismatch(_ card1: Card, _ card2: Card) {
        // 显示匹配失败的效果
        var mismatch_views: [CardView] = []
        for card_view in card_views {
            if card_view.card.id == card1.id || card_view.card.id == card2.id {
                mismatch_views.append(card_view)
            }
        }
        
        // 显示红色闪烁效果，完成后盖牌
        if mismatch_views.count == 2 {
            var completed_count = 0
            let total_count = 2
            
            let completion_handler = { [weak self] in
                completed_count += 1
                if completed_count == total_count {
                    // 两个卡片的闪烁效果都完成后，盖牌
                    self?.flip_cards_back()
                }
            }
            
            mismatch_views[0].show_mismatch(completion: completion_handler)
            mismatch_views[1].show_mismatch(completion: completion_handler)
        } else {
            // 如果找不到对应的卡片视图，直接盖牌
            flip_cards_back()
        }
    }
    
    private func flip_cards_back() {
        // 先更新游戏管理器中的卡片状态
        game_manager.flip_cards_back()
        
        // 然后更新UI
        for card_view in card_views {
            if card_view.card.is_flipped && !card_view.card.is_matched {
                card_view.flip_back()
            }
        }
        update_card_views()
    }
    
    private func show_celebration_effect() {
        // 创建庆祝效果的标签
        let celebration_label = UILabel()
        celebration_label.text = "Great Match! 🎉"
        celebration_label.textColor = UIColor.systemGreen
        celebration_label.font = UIFont.boldSystemFont(ofSize: 24)
        celebration_label.textAlignment = .center
        celebration_label.alpha = 0.0
        celebration_label.translatesAutoresizingMaskIntoConstraints = false
        
        game_board_view.addSubview(celebration_label)
        
        // 设置约束
        NSLayoutConstraint.activate([
            celebration_label.centerXAnchor.constraint(equalTo: game_board_view.centerXAnchor),
            celebration_label.centerYAnchor.constraint(equalTo: game_board_view.centerYAnchor)
        ])
        
        // 庆祝动画
        UIView.animate(withDuration: 0.5, animations: {
            celebration_label.alpha = 1.0
            celebration_label.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
        }) { _ in
            UIView.animate(withDuration: 0.3, animations: {
                celebration_label.alpha = 0.0
                celebration_label.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
            }) { _ in
                celebration_label.removeFromSuperview()
            }
        }
    }
    
    private func handle_game_complete(time: TimeInterval, score: Int) {
        stop_timer()
        
        // Show completion alert
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        let time_string = String(format: "%02d:%02d", minutes, seconds)
        
        let alert = UIAlertController(
            title: "Game Complete!",
            message: "You've completed the game!\nTime: \(time_string)\nScore: \(score)",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Back to Home", style: .default) { [weak self] _ in
            self?.navigationController?.popViewController(animated: true)
        })
        
        present(alert, animated: true)
    }
    
    private func handle_no_moves() {
        // Show alert for no more moves
        let alert = UIAlertController(
            title: "No More Moves",
            message: "There are no more possible moves. Game over!",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Back to Home", style: .default) { [weak self] _ in
            self?.navigationController?.popViewController(animated: true)
        })
        
        present(alert, animated: true)
    }
    
    private func highlight_cards(_ card1: Card, _ card2: Card) {
        // Find the card views and highlight them
        for card_view in card_views {
            if card_view.card.id == card1.id || card_view.card.id == card2.id {
                card_view.highlight()
            }
        }
    }
    
    // MARK: - UI Updates
    private func update_ui() {
        // Update labels
        flip_count_label.text = "Flips: \(game_manager.flip_count)"
        
        // Calculate estimated score based on flip count
        let base_score: Int
        switch game_mode {
        case .normal:
            base_score = 1000
        case .challenge:
            base_score = 2000
        case .easy:
            base_score = 500
        }
        let flip_penalty = game_manager.flip_count * 10
        let hint_bonus = game_manager.hints_remaining * 50
        let shuffle_bonus = game_manager.shuffles_remaining * 50
        let estimated_score = max(base_score - flip_penalty + hint_bonus + shuffle_bonus, 0)
        score_label.text = "Score: \(estimated_score)"
        
        pairs_label.text = "Pairs: \(game_manager.matched_pairs)/\(game_manager.total_pairs)"
        
        // Update button titles
        hint_button.setTitle("Hint (\(game_manager.hints_remaining))", for: .normal)
        shuffle_button.setTitle("Shuffle (\(game_manager.shuffles_remaining))", for: .normal)
        
        // Disable buttons if no uses remaining
        hint_button.isEnabled = game_manager.hints_remaining > 0
        shuffle_button.isEnabled = game_manager.shuffles_remaining > 0
        
        // Update alpha for disabled buttons
        hint_button.alpha = game_manager.hints_remaining > 0 ? 1.0 : 0.5
        shuffle_button.alpha = game_manager.shuffles_remaining > 0 ? 1.0 : 0.5
    }
    
    private func update_card_views() {
        // Update all card views to reflect the current state
        for (index, card_view) in card_views.enumerated() {
            if index < game_manager.cards.count {
                card_view.update_with(card: game_manager.cards[index])
            }
        }
    }
    
    private func show_pause_overlay() {
        let pause_overlay = UIView(frame: game_board_view.bounds)
        pause_overlay.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        pause_overlay.tag = 999 // Tag for easy removal
        
        let pause_label = UILabel()
        pause_label.text = "GAME PAUSED"
        pause_label.textColor = .white
        pause_label.font = UIFont.systemFont(ofSize: 30, weight: .bold)
        pause_label.translatesAutoresizingMaskIntoConstraints = false
        
        pause_overlay.addSubview(pause_label)
        game_board_view.addSubview(pause_overlay)
        
        NSLayoutConstraint.activate([
            pause_label.centerXAnchor.constraint(equalTo: pause_overlay.centerXAnchor),
            pause_label.centerYAnchor.constraint(equalTo: pause_overlay.centerYAnchor)
        ])
    }
    
    private func remove_pause_overlay() {
        if let overlay = game_board_view.viewWithTag(999) {
            overlay.removeFromSuperview()
        }
    }
    
    // MARK: - Timer
    private func start_timer() {
        stop_timer()
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(update_timer), userInfo: nil, repeats: true)
        remove_pause_overlay()
    }
    
    private func stop_timer() {
        timer?.invalidate()
        timer = nil
    }
    
    @objc private func update_timer() {
        elapsed_time += 1
        update_ui()
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
}

// MARK: - CardViewDelegate
extension GameViewController: CardViewDelegate {
    func card_tapped(_ cardView: CardView) {
        // 检查卡片是否可以翻开（已匹配的不能翻，已翻开的不能翻）
        guard !cardView.card.is_matched && !cardView.card.is_flipped else { return }
        
        // 翻开卡片
        game_manager.flip_card(cardView.card)
        cardView.flip()
        update_ui()
    }
}

// MARK: - CardView
protocol CardViewDelegate: AnyObject {
    func card_tapped(_ cardView: CardView)
}

class CardView: UIView {
    // MARK: - Properties
    var card: Card
    weak var delegate: CardViewDelegate?
    
    let front_view = UIImageView()
    let back_view = UIImageView()
    var is_flipped = false
    
    // MARK: - Initialization
    init(frame: CGRect, card: Card) {
        self.card = card
        super.init(frame: frame)
        setup_views()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    private func setup_views() {
        // Setup container - 麻将牌通常是长方形的，调整圆角
        layer.cornerRadius = 4
        clipsToBounds = true
        
        // Setup back view (initially visible) - 麻将牌背面设计
        back_view.backgroundColor = UIColor(red: 0.1, green: 0.5, blue: 0.2, alpha: 1.0) // 深绿色背景
        back_view.layer.cornerRadius = 4
        back_view.layer.masksToBounds = true
        back_view.frame = bounds
        back_view.contentMode = .scaleAspectFit
        addSubview(back_view)
        
        // 添加渐变背景
        let gradient_layer = CAGradientLayer()
        gradient_layer.frame = back_view.bounds
        gradient_layer.colors = [
            UIColor(red: 0.2, green: 0.6, blue: 0.3, alpha: 1.0).cgColor,
            UIColor(red: 0.1, green: 0.4, blue: 0.2, alpha: 1.0).cgColor
        ]
        gradient_layer.startPoint = CGPoint(x: 0, y: 0)
        gradient_layer.endPoint = CGPoint(x: 1, y: 1)
        back_view.layer.addSublayer(gradient_layer)
        
        // 添加麻将背面的装饰边框
        let border_view = UIView(frame: CGRect(x: 3, y: 3, width: bounds.width - 6, height: bounds.height - 6))
        border_view.backgroundColor = .clear
        border_view.layer.cornerRadius = 3
        border_view.layer.borderWidth = 2
        border_view.layer.borderColor = UIColor(white: 1.0, alpha: 0.4).cgColor
        back_view.addSubview(border_view)
        
        // 简化麻将背面设计，只保留白线框
        
        // Setup front view (initially hidden) - 麻将牌前面通常是象牙色的
        front_view.backgroundColor = UIColor(red: 0.98, green: 0.98, blue: 0.94, alpha: 1.0) // 象牙色
        front_view.layer.cornerRadius = 4
        front_view.layer.masksToBounds = true
        front_view.frame = bounds
        front_view.contentMode = .scaleAspectFit
        front_view.isHidden = true
        addSubview(front_view)
        
        // 添加麻将牌的边框
        front_view.layer.borderWidth = 1
        front_view.layer.borderColor = UIColor(white: 0.8, alpha: 1.0).cgColor
        
        // 添加麻将牌的图案容器 - 调整为贴紧边缘，减少空白
        let pattern_container = UIView(frame: CGRect(x: bounds.width * 0.02, y: bounds.height * 0.02, width: bounds.width * 0.96, height: bounds.height * 0.96))
        pattern_container.backgroundColor = .clear
        front_view.addSubview(pattern_container)
        
        // 添加麻将牌的图案
        let image_view = UIImageView(frame: pattern_container.bounds)
        image_view.image = card.model.image
        image_view.contentMode = .scaleAspectFit
        image_view.tag = 100 // 添加标签以便后续更新
        pattern_container.addSubview(image_view)
        
        // Add tap gesture
        let tap_gesture = UITapGestureRecognizer(target: self, action: #selector(handle_tap))
        addGestureRecognizer(tap_gesture)
        
        // Add shadow
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowRadius = 2
        layer.shadowOpacity = 0.5
        
        // Set initial state
        if card.is_matched {
            is_flipped = true
            front_view.isHidden = false
            back_view.isHidden = true
            isHidden = true
            alpha = 0.0
        }
    }
    
    // MARK: - Actions
    @objc private func handle_tap() {
        // 已匹配的卡片不能点击
        if card.is_matched {
            return
        }
        
        // 未翻开的卡片可以点击（用于翻开）
        // 已翻开的卡片也可以点击（用于匹配选择）
        delegate?.card_tapped(self)
    }
    
    // MARK: - Public Methods
    func flip() {
        guard !is_flipped else { return }
        
        is_flipped = true
        
        UIView.transition(from: back_view,
                          to: front_view,
                          duration: 0.3,
                          options: [.transitionFlipFromLeft, .showHideTransitionViews],
                          completion: nil)
    }
    
    func flip_back() {
        guard is_flipped && !card.is_matched else { return }
        
        is_flipped = false
        
        UIView.transition(from: front_view,
                          to: back_view,
                          duration: 0.3,
                          options: [.transitionFlipFromRight, .showHideTransitionViews],
                          completion: nil)
    }
    
    func animate_match() {
        // Fade out slightly and scale down
        UIView.animate(withDuration: 0.3, animations: {
            self.alpha = 0.6
            self.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        })
    }
    
    func animate_elimination() {
        // 真正的消除效果：先放大再缩小并淡出，然后隐藏
        UIView.animate(withDuration: 0.3, animations: {
            // 第一阶段：放大并稍微旋转
            self.transform = CGAffineTransform(scaleX: 1.3, y: 1.3).rotated(by: .pi / 12)
            self.alpha = 0.8
        }) { _ in
            UIView.animate(withDuration: 0.2, animations: {
                // 第二阶段：缩小并完全淡出
                self.transform = CGAffineTransform(scaleX: 0.1, y: 0.1).rotated(by: .pi / 6)
                self.alpha = 0.0
            }) { _ in
                // 动画完成后隐藏卡片
                self.isHidden = true
                self.transform = .identity
            }
        }
    }
    
    func highlight() {
        // Add a pulsing animation to highlight the card
        let pulse_animation = CABasicAnimation(keyPath: "transform.scale")
        pulse_animation.duration = 0.5
        pulse_animation.fromValue = 1.0
        pulse_animation.toValue = 1.1
        pulse_animation.autoreverses = true
        pulse_animation.repeatCount = 3
        layer.add(pulse_animation, forKey: "pulse")
        
        // Add a glow effect
        layer.borderWidth = 2
        layer.borderColor = UIColor.yellow.cgColor
        
        // Remove the highlight after a delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
            self?.layer.borderWidth = 0
        }
    }
    
    func highlight_selection() {
        // 选中卡片的高亮效果
        layer.borderWidth = 3
        layer.borderColor = UIColor.blue.cgColor
        
        // 添加轻微的缩放效果
        UIView.animate(withDuration: 0.2, animations: {
            self.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
        })
    }
    
    func show_mismatch(completion: (() -> Void)? = nil) {
        // 匹配失败的效果
        layer.borderWidth = 3
        layer.borderColor = UIColor.red.cgColor
        
        // 添加震动效果
        let shake_animation = CABasicAnimation(keyPath: "transform.translation.x")
        shake_animation.duration = 0.1
        shake_animation.fromValue = -5
        shake_animation.toValue = 5
        shake_animation.autoreverses = true
        shake_animation.repeatCount = 3
        layer.add(shake_animation, forKey: "shake")
        
        // 添加红色闪烁效果
        UIView.animate(withDuration: 0.1, animations: {
            self.alpha = 0.7
        }) { _ in
            UIView.animate(withDuration: 0.1, animations: {
                self.alpha = 1.0
            }) { _ in
                UIView.animate(withDuration: 0.1, animations: {
                    self.alpha = 0.7
                }) { _ in
                    UIView.animate(withDuration: 0.1, animations: {
                        self.alpha = 1.0
                    }) { _ in
                        // 闪烁效果完成后执行回调
                        completion?()
                    }
                }
            }
        }
        
        // 移除效果
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            self?.layer.borderWidth = 0
            self?.transform = .identity
        }
    }
    
    func update_with(card: Card) {
        self.card = card
        
        // 更新前面视图中的图像
        for subview in front_view.subviews {
            if let container = subview as? UIView {
                for imageView in container.subviews {
                    if let imgView = imageView as? UIImageView, imgView.tag == 100 {
                        imgView.image = card.model.image
                    }
                }
            }
        }
        
        // Reset view state
        if card.is_matched {
            // 已匹配的牌应该被隐藏（消除效果）
            is_flipped = true
            front_view.isHidden = false
            back_view.isHidden = true
            isHidden = true
            alpha = 0.0
            transform = .identity
        } else if card.is_flipped {
            // 已翻开但未匹配的牌
            is_flipped = true
            front_view.isHidden = false
            back_view.isHidden = true
            alpha = 1.0
            transform = .identity
            isHidden = false
        } else {
            // 未翻开的牌
            is_flipped = false
            front_view.isHidden = true
            back_view.isHidden = false
            alpha = 1.0
            transform = .identity
            isHidden = false
        }
    }
}
