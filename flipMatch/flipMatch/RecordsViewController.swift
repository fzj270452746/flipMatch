

import UIKit

class RecordsViewController: UIViewController {
    
    // MARK: - Device Adapter
    private let device_adapter = DeviceAdapter.shared
    
    // MARK: - UI Components
    private let background_image_view = UIImageView()
    private let overlay_view = UIView()
    private let segment_control = UISegmentedControl(items: ["Normal", "Challenge", "Recent"])
    private let table_view = UITableView()
    private let no_records_label = UILabel()
    private let clear_button = UIButton()
    
    // MARK: - Properties
    private let record_manager = GameRecordManager.shared
    private var displayed_records: [GameRecord] = []
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setup_ui()
        load_records()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        navigationItem.title = "Game Records"
        
        // 每次进入页面时重新加载记录
        load_records()
    }
    
    // MARK: - UI Setup
    private func setup_ui() {
        setup_background()
        setup_overlay()
        setup_segment_control()
        setup_table_view()
        setup_no_records_label()
        setup_clear_button()
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
    
    private func setup_segment_control() {
        // Customize appearance
        segment_control.selectedSegmentIndex = 0
        segment_control.backgroundColor = UIColor(white: 0.2, alpha: 0.7)
        segment_control.selectedSegmentTintColor = UIColor(red: 0.8, green: 0.2, blue: 0.2, alpha: 0.8)
        segment_control.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .normal)
        segment_control.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
        segment_control.translatesAutoresizingMaskIntoConstraints = false
        overlay_view.addSubview(segment_control)
        
        // Add action
        segment_control.addTarget(self, action: #selector(segment_changed), for: .valueChanged)
        
        NSLayoutConstraint.activate([
            segment_control.topAnchor.constraint(equalTo: overlay_view.topAnchor, constant: 20),
            segment_control.leadingAnchor.constraint(equalTo: overlay_view.leadingAnchor, constant: 20),
            segment_control.trailingAnchor.constraint(equalTo: overlay_view.trailingAnchor, constant: -20),
            segment_control.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    private func setup_table_view() {
        table_view.backgroundColor = .clear
        table_view.separatorStyle = .singleLine
        table_view.separatorColor = UIColor.white.withAlphaComponent(0.3)
        table_view.translatesAutoresizingMaskIntoConstraints = false
        overlay_view.addSubview(table_view)
        
        // Register cell
        table_view.register(RecordCell.self, forCellReuseIdentifier: "RecordCell")
        
        // Set delegates
        table_view.dataSource = self
        table_view.delegate = self
        
        NSLayoutConstraint.activate([
            table_view.topAnchor.constraint(equalTo: segment_control.bottomAnchor, constant: 20),
            table_view.leadingAnchor.constraint(equalTo: overlay_view.leadingAnchor, constant: 10),
            table_view.trailingAnchor.constraint(equalTo: overlay_view.trailingAnchor, constant: -10),
            table_view.bottomAnchor.constraint(equalTo: overlay_view.bottomAnchor, constant: -70)
        ])
    }
    
    private func setup_no_records_label() {
        no_records_label.text = "No records found"
        no_records_label.textColor = .white
        no_records_label.font = UIFont.systemFont(ofSize: 18)
        no_records_label.textAlignment = .center
        no_records_label.translatesAutoresizingMaskIntoConstraints = false
        no_records_label.isHidden = true
        overlay_view.addSubview(no_records_label)
        
        NSLayoutConstraint.activate([
            no_records_label.centerXAnchor.constraint(equalTo: table_view.centerXAnchor),
            no_records_label.centerYAnchor.constraint(equalTo: table_view.centerYAnchor)
        ])
    }
    
    private func setup_clear_button() {
        clear_button.setTitle("Clear All Records", for: .normal)
        clear_button.setTitleColor(.white, for: .normal)
        clear_button.backgroundColor = UIColor(red: 0.8, green: 0.2, blue: 0.2, alpha: 0.8)
        clear_button.layer.cornerRadius = 15
        clear_button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        clear_button.translatesAutoresizingMaskIntoConstraints = false
        overlay_view.addSubview(clear_button)
        
        // Add shadow
        clear_button.layer.shadowColor = UIColor.black.cgColor
        clear_button.layer.shadowOffset = CGSize(width: 0, height: 2)
        clear_button.layer.shadowRadius = 3
        clear_button.layer.shadowOpacity = 0.5
        
        // Add action
        clear_button.addTarget(self, action: #selector(clear_records), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            clear_button.topAnchor.constraint(equalTo: table_view.bottomAnchor, constant: 15),
            clear_button.centerXAnchor.constraint(equalTo: overlay_view.centerXAnchor),
            clear_button.widthAnchor.constraint(equalToConstant: 200),
            clear_button.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    // MARK: - Data Loading
    private func load_records() {
        
        switch segment_control.selectedSegmentIndex {
        case 0: // Normal Mode
            displayed_records = record_manager.get_top_records(mode: .normal)
        case 1: // Challenge Mode
            displayed_records = record_manager.get_top_records(mode: .challenge)
        case 2: // Recent
            displayed_records = record_manager.get_recent_records()
        default:
            displayed_records = []
        }
        
        update_ui()
    }
    
    private func update_ui() {
        table_view.reloadData()
        no_records_label.isHidden = !displayed_records.isEmpty
    }
    
    // MARK: - Actions
    @objc private func segment_changed() {
        load_records()
    }
    
    @objc private func clear_records() {
        let alert = UIAlertController(
            title: "Clear Records",
            message: "Are you sure you want to clear all game records? This action cannot be undone.",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        alert.addAction(UIAlertAction(title: "Clear", style: .destructive) { [weak self] _ in
            self?.record_manager.clear_records()
            self?.load_records()
        })
        
//        // 添加测试按钮
//        alert.addAction(UIAlertAction(title: "Add Test Record", style: .default) { [weak self] _ in
//            self?.add_test_record()
//        })
        
        present(alert, animated: true)
    }
    
    private func add_test_record() {
        let test_record = GameRecord(
            mode: .normal,
            time: 120.0,
            score: 850,
            date: Date()
        )
        record_manager.add_record(test_record)
        load_records()
        
        let success_alert = UIAlertController(
            title: "Test Record Added",
            message: "已添加测试记录，请查看记录列表",
            preferredStyle: .alert
        )
        success_alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(success_alert, animated: true)
    }
}

// MARK: - UITableViewDataSource
extension RecordsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return displayed_records.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "RecordCell", for: indexPath) as? RecordCell else {
            return UITableViewCell()
        }
        
        let record = displayed_records[indexPath.row]
        cell.configure(with: record, rank: indexPath.row + 1)
        return cell
    }
}

// MARK: - UITableViewDelegate
extension RecordsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
}

// MARK: - RecordCell
class RecordCell: UITableViewCell {
    // MARK: - UI Components
    private let rank_label = UILabel()
    private let mode_label = UILabel()
    private let score_label = UILabel()
    private let time_label = UILabel()
    private let date_label = UILabel()
    private let container_view = UIView()
    
    // MARK: - Initialization
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup_ui()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI Setup
    private func setup_ui() {
        backgroundColor = .clear
        selectionStyle = .none
        
        // Container view
        container_view.backgroundColor = UIColor(white: 0.1, alpha: 0.5)
        container_view.layer.cornerRadius = 10
        container_view.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(container_view)
        
        // Rank label
        rank_label.textColor = UIColor(red: 0.9, green: 0.7, blue: 0.3, alpha: 1.0) // Gold color
        rank_label.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        rank_label.translatesAutoresizingMaskIntoConstraints = false
        container_view.addSubview(rank_label)
        
        // Mode label
        mode_label.textColor = .white
        mode_label.font = UIFont.systemFont(ofSize: 14)
        mode_label.translatesAutoresizingMaskIntoConstraints = false
        container_view.addSubview(mode_label)
        
        // Score label
        score_label.textColor = .white
        score_label.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        score_label.translatesAutoresizingMaskIntoConstraints = false
        container_view.addSubview(score_label)
        
        // Time label
        time_label.textColor = .white
        time_label.font = UIFont.systemFont(ofSize: 14)
        time_label.translatesAutoresizingMaskIntoConstraints = false
        container_view.addSubview(time_label)
        
        // Date label
        date_label.textColor = UIColor.white.withAlphaComponent(0.7)
        date_label.font = UIFont.systemFont(ofSize: 12)
        date_label.translatesAutoresizingMaskIntoConstraints = false
        container_view.addSubview(date_label)
        
        // Layout
        NSLayoutConstraint.activate([
            container_view.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5),
            container_view.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 5),
            container_view.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -5),
            container_view.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5),
            
            rank_label.leadingAnchor.constraint(equalTo: container_view.leadingAnchor, constant: 15),
            rank_label.centerYAnchor.constraint(equalTo: container_view.centerYAnchor),
            rank_label.widthAnchor.constraint(equalToConstant: 30),
            
            mode_label.topAnchor.constraint(equalTo: container_view.topAnchor, constant: 10),
            mode_label.leadingAnchor.constraint(equalTo: rank_label.trailingAnchor, constant: 10),
            
            score_label.topAnchor.constraint(equalTo: mode_label.bottomAnchor, constant: 5),
            score_label.leadingAnchor.constraint(equalTo: mode_label.leadingAnchor),
            
            time_label.centerYAnchor.constraint(equalTo: mode_label.centerYAnchor),
            time_label.trailingAnchor.constraint(equalTo: container_view.trailingAnchor, constant: -15),
            
            date_label.centerYAnchor.constraint(equalTo: score_label.centerYAnchor),
            date_label.trailingAnchor.constraint(equalTo: time_label.trailingAnchor)
        ])
    }
    
    // MARK: - Configuration
    func configure(with record: GameRecord, rank: Int) {
        // Format rank
        rank_label.text = "#\(rank)"
        
        // Format mode
        mode_label.text = record.mode == .normal ? "Normal Mode" : "Challenge Mode"
        
        // Format score
        score_label.text = "Score: \(record.score)"
        
        // Format time
        let minutes = Int(record.time) / 60
        let seconds = Int(record.time) % 60
        time_label.text = String(format: "Time: %02d:%02d", minutes, seconds)
        
        // Format date
        let date_formatter = DateFormatter()
        date_formatter.dateStyle = .short
        date_formatter.timeStyle = .short
        date_label.text = date_formatter.string(from: record.date)
        
        // Highlight top 3
        if rank <= 3 {
            container_view.backgroundColor = UIColor(red: 0.2, green: 0.2, blue: 0.3, alpha: 0.7)
            rank_label.font = UIFont.systemFont(ofSize: 20, weight: .bold)
            
            // Special colors for top 3
            switch rank {
            case 1:
                rank_label.textColor = UIColor(red: 1.0, green: 0.85, blue: 0.0, alpha: 1.0) // Gold
            case 2:
                rank_label.textColor = UIColor(red: 0.75, green: 0.75, blue: 0.75, alpha: 1.0) // Silver
            case 3:
                rank_label.textColor = UIColor(red: 0.8, green: 0.5, blue: 0.2, alpha: 1.0) // Bronze
            default:
                break
            }
        } else {
            container_view.backgroundColor = UIColor(white: 0.1, alpha: 0.5)
            rank_label.font = UIFont.systemFont(ofSize: 18, weight: .bold)
            rank_label.textColor = UIColor(red: 0.9, green: 0.7, blue: 0.3, alpha: 1.0)
        }
    }
}
