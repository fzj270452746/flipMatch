
import Foundation
import UIKit

enum GameMode: Codable {
    case normal
    case challenge
    case easy // 傻瓜模式
}

class GameManager {
    // Singleton instance
    static let shared = GameManager()
    
    // MARK: - Game Properties
    private(set) var current_mode: GameMode = .normal
    private(set) var cards: [Card] = []
    private(set) var flipped_cards: [Card] = []
    private(set) var matched_pairs = 0
    private(set) var total_pairs = 54 // 108 cards = 54 pairs
    private(set) var game_start_time: Date?
    private(set) var game_end_time: Date?
    private(set) var hints_remaining = 3
    private(set) var shuffles_remaining = 3
    private(set) var flip_count = 0 // 翻牌次数
    
    // MARK: - Game State
    private(set) var is_game_active = false
    private(set) var is_game_paused = false
    
    // MARK: - Callbacks
    var on_match: ((Card, Card) -> Void)?
    var on_mismatch: ((Card, Card) -> Void)?
    var on_game_complete: ((TimeInterval, Int) -> Void)?
    var on_hint_used: ((Card, Card) -> Void)?
    var on_shuffle: (() -> Void)?
    
    // MARK: - Initialization
    private init() {}
    
    // MARK: - Game Setup
    func start_game(mode: GameMode) {
        current_mode = mode
        matched_pairs = 0
        is_game_active = true
        is_game_paused = false
        game_start_time = Date()
        game_end_time = nil
        flip_count = 0 // 重置翻牌次数
        
        // Set up hints and shuffles based on game mode
        if mode == .normal {
            hints_remaining = 3
            shuffles_remaining = 3
        } else if mode == .challenge {
            hints_remaining = 0
            shuffles_remaining = 1
        } else { // easy mode
            hints_remaining = 5
            shuffles_remaining = 5
        }
        
        // Initialize and shuffle cards
        initialize_cards()
        shuffle_cards()
        
        // 初始化卡片位置信息
        initialize_card_positions()
    }
    
    private func initialize_cards() {
        cards = []
        flipped_cards = []
        
        if current_mode == .easy {
            // 傻瓜模式：从完整牌组中随机选择12张不同的牌，然后复制成24张
            let all_models = [
                // Dots (Tong) 1-9
                image_tong_1, image_tong_2, image_tong_3, image_tong_4, image_tong_5,
                image_tong_6, image_tong_7, image_tong_8, image_tong_9,
                // Bamboo (Tiao) 1-9
                image_tiao_1, image_tiao_2, image_tiao_3, image_tiao_4, image_tiao_5,
                image_tiao_6, image_tiao_7, image_tiao_8, image_tiao_9,
                // Characters (Wan) 1-9
                image_wan_1, image_wan_2, image_wan_3, image_wan_4, image_wan_5,
                image_wan_6, image_wan_7, image_wan_8, image_wan_9
            ]
            
            // 随机选择12张不同的牌
            let shuffled_models = all_models.shuffled()
            let selected_models = Array(shuffled_models.prefix(12))
            
            // 创建2张相同的牌 (24 cards total)
            var id = 0
            for model in selected_models {
                for _ in 0..<2 {
                    let card = Card(id: id, model: model, is_flipped: false, is_matched: false)
                    cards.append(card)
                    id += 1
                }
            }
            
            // 更新总对数
            total_pairs = 12 // 24 cards = 12 pairs
        } else {
            // 普通模式和挑战模式：使用完整的1-9
            let mahjong_models = [
                // Dots (Tong)
                image_tong_1, image_tong_2, image_tong_3, image_tong_4, image_tong_5,
                image_tong_6, image_tong_7, image_tong_8, image_tong_9,
                // Bamboo (Tiao)
                image_tiao_1, image_tiao_2, image_tiao_3, image_tiao_4, image_tiao_5,
                image_tiao_6, image_tiao_7, image_tiao_8, image_tiao_9,
                // Characters (Wan)
                image_wan_1, image_wan_2, image_wan_3, image_wan_4, image_wan_5,
                image_wan_6, image_wan_7, image_wan_8, image_wan_9
            ]
            
            // Create 4 copies of each card
            var id = 0
            for model in mahjong_models {
                for _ in 0..<4 {
                    let card = Card(id: id, model: model, is_flipped: false, is_matched: false)
                    cards.append(card)
                    id += 1
                }
            }
            
            // 更新总对数
            total_pairs = 54 // 108 cards = 54 pairs
        }
    }
    
    // MARK: - Game Actions
    // 存储卡片的位置信息
    private var card_positions: [Int: (row: Int, column: Int)] = [:]
    private var flipped_positions: Set<Int> = []
    private let rows = 9
    private let columns = 12
    
    // 初始化卡片位置
    func initialize_card_positions() {
        card_positions.removeAll()
        flipped_positions.removeAll()
        
        for i in 0..<cards.count {
            let row = i / columns
            let column = i % columns
            card_positions[i] = (row, column)
        }
    }
    
    // 自动翻开最上面和最下面一排的麻将牌
    private func auto_flip_outer_rows() {
        for i in 0..<cards.count {
            let row = i / columns
            let column = i % columns
            
            // 翻开最上面一排（row == 0）和最下面一排（row == rows - 1）
            if row == 0 || row == rows - 1 {
                cards[i].is_flipped = true
                flipped_positions.insert(i)
                flipped_cards.append(cards[i])
            }
        }
    }
    
    // 判断卡片是否在最外层
    func is_card_on_outer_layer(_ card_index: Int) -> Bool {
        guard let position = card_positions[card_index] else { return false }
        
        // 最上排或最下排
        if position.row == 0 || position.row == rows - 1 {
            return true
        }
        
        // 最左列或最右列
        if position.column == 0 || position.column == columns - 1 {
            return true
        }
        
        return false
    }
    
    // 判断卡片是否在第二层
    func is_card_on_second_layer(_ card_index: Int) -> Bool {
        guard let position = card_positions[card_index] else { return false }
        
        // 第二排或倒数第二排
        if position.row == 1 || position.row == rows - 2 {
            return position.column >= 1 && position.column <= columns - 2
        }
        
        // 第二列或倒数第二列
        if position.column == 1 || position.column == columns - 2 {
            return position.row >= 1 && position.row <= rows - 2
        }
        
        return false
    }
    
    // 判断外层是否已经全部翻开或匹配
    func is_outer_layer_cleared() -> Bool {
        for (index, _) in card_positions {
            if is_card_on_outer_layer(index) {
                // 如果有外层卡片既没有翻开也没有匹配，则外层未清除
                if !flipped_positions.contains(index) && !cards[index].is_matched {
                    return false
                }
            }
        }
        return true
    }
    
    // 判断第二层是否已经全部翻开或匹配
    func is_second_layer_cleared() -> Bool {
        for (index, _) in card_positions {
            if is_card_on_second_layer(index) {
                // 如果有第二层卡片既没有翻开也没有匹配，则第二层未清除
                if !flipped_positions.contains(index) && !cards[index].is_matched {
                    return false
                }
            }
        }
        return true
    }
    
    // 判断卡片是否可以翻开
    func can_flip_card(_ card_index: Int) -> Bool {
        // 已匹配的卡片不能翻
        if cards[card_index].is_matched {
            return false
        }
        
        // 已经翻开的卡片不能再翻
        if flipped_positions.contains(card_index) {
            return false
        }
        
        // 外层卡片总是可以翻
        if is_card_on_outer_layer(card_index) {
            return true
        }
        
        // 如果外层已清除，第二层卡片可以翻
        if is_card_on_second_layer(card_index) && is_outer_layer_cleared() {
            return true
        }
        
        // 如果第二层已清除，内层卡片可以翻
        if !is_card_on_outer_layer(card_index) && !is_card_on_second_layer(card_index) && is_outer_layer_cleared() && is_second_layer_cleared() {
            return true
        }
        
        // 如果不满足上述条件，则不能翻开
        return false
    }
    
    func flip_card(_ card: Card) {
        guard is_game_active && !is_game_paused else { return }
        
        // 找到卡片索引
        guard let card_index = cards.firstIndex(where: { $0.id == card.id }) else { return }
        
        // 检查卡片是否可以翻开（已匹配的不能翻，已翻开的不能翻）
        guard !cards[card_index].is_matched && !cards[card_index].is_flipped else { return }
        
        // 更新卡片状态为已翻开
        cards[card_index].is_flipped = true
        flip_count += 1
        
        // 添加到已翻开卡片列表
        flipped_cards.append(card)
        
        // 检查是否有两张翻开的卡片
        if flipped_cards.count == 2 {
            check_for_match()
        }
    }
    
    // 玩家选择卡片进行匹配
    func select_card_for_match(_ card: Card) -> Bool {
        guard is_game_active && !is_game_paused else { return false }
        
        // 找到卡片索引
        guard let card_index = cards.firstIndex(where: { $0.id == card.id }) else { return false }
        
        // 检查卡片是否已翻开且未匹配
        guard cards[card_index].is_flipped && !cards[card_index].is_matched else { return false }
        
        // 如果已经有选中的卡片，检查匹配
        if flipped_cards.count == 1 {
            let first_card = flipped_cards[0]
            if first_card.model.val == card.model.val {
                // 匹配成功
                match_cards(first_card, card)
                return true
            } else {
                // 匹配失败
                mismatch_cards(first_card, card)
                return false
            }
        } else {
            // 选择第一张卡片
            flipped_cards.append(card)
            return true
        }
    }
    
    // 匹配成功
    private func match_cards(_ card1: Card, _ card2: Card) {
        // 找到卡片索引并标记为已匹配
        if let index1 = cards.firstIndex(where: { $0.id == card1.id }) {
            cards[index1].is_matched = true
            flipped_positions.remove(index1)
        }
        if let index2 = cards.firstIndex(where: { $0.id == card2.id }) {
            cards[index2].is_matched = true
            flipped_positions.remove(index2)
        }
        
        matched_pairs += 1
        on_match?(card1, card2)
        
        // 清空选中的卡片
        flipped_cards = []
        
        // 检查游戏是否完成
        if matched_pairs == total_pairs {
            end_game()
        }
    }
    
    // 匹配失败
    private func mismatch_cards(_ card1: Card, _ card2: Card) {
        on_mismatch?(card1, card2)
        
        // 清空选中的卡片
        flipped_cards = []
    }
    
    private func check_for_match() {
        guard flipped_cards.count == 2 else { return }
        
        let first_card = flipped_cards[0]
        let second_card = flipped_cards[1]
        
        // Check if the cards match
        // 所有模式都只匹配数字，不匹配花色（麻将规则）
        let is_match = first_card.model.val == second_card.model.val
        
        if is_match {
            // Mark cards as matched
            if let index = cards.firstIndex(where: { $0.id == first_card.id }) {
                cards[index].is_matched = true
                flipped_positions.remove(index)
            }
            if let index = cards.firstIndex(where: { $0.id == second_card.id }) {
                cards[index].is_matched = true
                flipped_positions.remove(index)
            }
            
            matched_pairs += 1
            on_match?(first_card, second_card)
            
            
            // Check if game is complete
            if matched_pairs == total_pairs {
                end_game()
            }
        } else {
            // Cards don't match，立即盖牌
            on_mismatch?(first_card, second_card)
            
            // 立即盖牌
            flip_cards_back()
        }
        
        // 清空当前翻开的卡片列表
        flipped_cards = []
    }
    
    // 重新盖牌
    func flip_cards_back() {
        // 找到所有已翻开但未匹配的卡片并盖回去
        for i in 0..<cards.count {
            if cards[i].is_flipped && !cards[i].is_matched {
                cards[i].is_flipped = false
            }
        }
        flipped_cards = []
    }
    
    func use_hint() -> (Card, Card)? {
        guard is_game_active && !is_game_paused && hints_remaining > 0 else { return nil }
        
        // Find unmatched cards that can be paired
        let unmatched_cards = cards.filter { !$0.is_matched }
        
        // Group by value
        var card_groups: [String: [Card]] = [:]
        for card in unmatched_cards {
            if card_groups[card.model.val] == nil {
                card_groups[card.model.val] = []
            }
            card_groups[card.model.val]?.append(card)
        }
        
        // Find a pair
        for (_, group) in card_groups {
            if group.count >= 2 {
                hints_remaining -= 1
                let pair = (group[0], group[1])
                on_hint_used?(pair.0, pair.1)
                return pair
            }
        }
        
        return nil
    }
    
    func shuffle_cards() {
        guard is_game_active && !is_game_paused else { return }
        
        if current_mode == .normal || shuffles_remaining > 0 {
            // 洗牌前先盖住所有未匹配的牌
            for i in 0..<cards.count {
                if !cards[i].is_matched {
                    cards[i].is_flipped = false
                }
            }
            flipped_cards = []
            
            // Only shuffle unmatched cards
            var unmatched_cards = cards.filter { !$0.is_matched }
            unmatched_cards.shuffle()
            
            // Replace unmatched cards in the original array
            var unmatched_index = 0
            for i in 0..<cards.count {
                if !cards[i].is_matched {
                    cards[i] = unmatched_cards[unmatched_index]
                    unmatched_index += 1
                }
            }
            
            if current_mode == .challenge {
                shuffles_remaining -= 1
            } else if current_mode == .normal {
                shuffles_remaining -= 1
            }
            
            on_shuffle?()
        }
    }
    
    func pause_game() {
        is_game_paused = true
    }
    
    func resume_game() {
        is_game_paused = false
    }
    
    func end_game() {
        is_game_active = false
        game_end_time = Date()
        
        if let start_time = game_start_time, let end_time = game_end_time {
            let time_taken = end_time.timeIntervalSince(start_time)
            let score = calculate_score(time_taken: time_taken)
            
            
            // Save game record
            let record = GameRecord(mode: current_mode, time: time_taken, score: score, date: end_time)
            GameRecordManager.shared.add_record(record)
            
            on_game_complete?(time_taken, score)
        } else {
        }
    }
    
    // MARK: - Scoring
    private func calculate_score(time_taken: TimeInterval) -> Int {
        // Base score depends on game mode
        let base_score: Int
        switch current_mode {
        case .normal:
            base_score = 1000
        case .challenge:
            base_score = 2000
        case .easy:
            base_score = 500
        }
        
        // 基于翻牌次数的计分：翻牌次数越少，分数越高
        let flip_penalty = flip_count * 10
        
        // Bonus for remaining hints and shuffles
        let hint_bonus = hints_remaining * 50
        let shuffle_bonus = shuffles_remaining * 50
        
        let final_score = base_score - flip_penalty + hint_bonus + shuffle_bonus
        return max(final_score, 0) // Ensure score is not negative
    }
    
    // MARK: - Helper Methods
    func get_card(at index: Int) -> Card? {
        guard index >= 0 && index < cards.count else { return nil }
        return cards[index]
    }
    
    func get_game_time() -> TimeInterval {
        guard let start_time = game_start_time else { return 0 }
        return Date().timeIntervalSince(start_time)
    }
    
    func check_for_possible_moves() -> Bool {
        // Find unmatched cards
        let unmatched_cards = cards.filter { !$0.is_matched }
        
        // Group by value
        var card_groups: [String: [Card]] = [:]
        for card in unmatched_cards {
            if card_groups[card.model.val] == nil {
                card_groups[card.model.val] = []
            }
            card_groups[card.model.val]?.append(card)
        }
        
        // Check if any group has at least 2 cards
        for (_, group) in card_groups {
            if group.count >= 2 {
                return true
            }
        }
        
        return false
    }
}

// MARK: - Card Model
struct Card: Equatable {
    let id: Int
    let model: FlipModel
    var is_flipped: Bool
    var is_matched: Bool
    
    static func == (lhs: Card, rhs: Card) -> Bool {
        return lhs.id == rhs.id
    }
}
