

import Foundation

struct GameRecord: Codable {
    let mode: GameMode
    let time: TimeInterval
    let score: Int
    let date: Date
    
    init(mode: GameMode, time: TimeInterval, score: Int, date: Date) {
        self.mode = mode
        self.time = time
        self.score = score
        self.date = date
    }
}

class GameRecordManager {
    // Singleton instance
    static let shared = GameRecordManager()
    
    // Key for UserDefaults
    private let records_key = "mahjong_flip_match_records"
    
    // Records array
    private(set) var records: [GameRecord] = []
    
    private init() {
        load_records()
    }
    
    // MARK: - Record Management
    func add_record(_ record: GameRecord) {
        records.append(record)
        save_records()
    }
    
    func clear_records() {
        records = []
        save_records()
    }
    
    // MARK: - Persistence
    private func save_records() {
        do {
            let data = try JSONEncoder().encode(records)
            UserDefaults.standard.set(data, forKey: records_key)
        } catch {
        }
    }
    
    private func load_records() {
        guard let data = UserDefaults.standard.data(forKey: records_key) else { 
            return
        }
        
        do {
            records = try JSONDecoder().decode([GameRecord].self, from: data)
        } catch {
        }
    }
    
    // MARK: - Record Queries
    func get_top_records(mode: GameMode, limit: Int = 10) -> [GameRecord] {
        return records
            .filter { $0.mode == mode }
            .sorted { $0.score > $1.score }
            .prefix(limit)
            .map { $0 }
    }
    
    func get_recent_records(limit: Int = 10) -> [GameRecord] {
        return records
            .sorted { $0.date > $1.date }
            .prefix(limit)
            .map { $0 }
    }
    
    func get_best_score(mode: GameMode) -> Int {
        return records
            .filter { $0.mode == mode }
            .map { $0.score }
            .max() ?? 0
    }
    
    func get_best_time(mode: GameMode) -> TimeInterval {
        return records
            .filter { $0.mode == mode }
            .map { $0.time }
            .min() ?? 0
    }
}
