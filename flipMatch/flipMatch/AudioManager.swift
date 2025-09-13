

import Foundation
import AVFoundation
import UIKit

class AudioManager {
    // 单例实例
    static let shared = AudioManager()
    
    // 音频播放器
    private var background_music_player: AVAudioPlayer?
    private var sound_effect_player: AVAudioPlayer?
    
    // 用户设置
    private let user_defaults = UserDefaults.standard
    private let background_music_key = "background_music_enabled"
    private let sound_effects_key = "sound_effects_enabled"
    
    // 初始化
    private init() {
        setup_audio_session()
    }
    
    // 设置音频会话
    private func setup_audio_session() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [.mixWithOthers])
            try AVAudioSession.sharedInstance().setActive(true)
            
        } catch {
            
        }
    }
    
    // 播放背景音乐
    func play_background_music() {
        // 检查用户是否启用了背景音乐
        if !user_defaults.bool(forKey: background_music_key, defaultValue: true) {

            return
        }
        
        // 如果已经在播放，则不重复播放
        if background_music_player?.isPlaying == true {
            return
        }
        
        // 尝试从Bundle中加载音乐文件
        var music_url: URL?
        
        // 首先尝试从Bundle中直接加载
        if let url = Bundle.main.url(forResource: "background_music", withExtension: "mp3") {
            music_url = url
        } else if let url = Bundle.main.url(forResource: "backgroud_music", withExtension: "mp3") {
            music_url = url
        } else if let url = Bundle.main.url(forResource: "background", withExtension: "mp3") {
            music_url = url
        }
        
        // 如果找到了音乐文件，播放它
        if let url = music_url {
            play_music_from_url(url)
        } else {
            // 尝试从Assets中加载（如果文件在Assets.xcassets中）
            if let data = NSDataAsset(name: "backgroud_music.mp3") {
                do {
                    background_music_player = try AVAudioPlayer(data: data.data)
                    background_music_player?.numberOfLoops = -1
                    background_music_player?.volume = 0.5
                    background_music_player?.play()
                } catch {
                }
            } else if let data = NSDataAsset(name: "backgroud_music") {
                do {
                    background_music_player = try AVAudioPlayer(data: data.data)
                    background_music_player?.numberOfLoops = -1
                    background_music_player?.volume = 0.5
                    background_music_player?.play()
                } catch {
                }
            } else {
            }
        }
    }
    
    private func play_music_from_url(_ url: URL) {
        do {
            background_music_player = try AVAudioPlayer(contentsOf: url)
            background_music_player?.numberOfLoops = -1 // 无限循环
            background_music_player?.volume = 0.5 // 设置音量
            background_music_player?.play()
        } catch {
        }
    }
    
    // 停止背景音乐
    func stop_background_music() {
        background_music_player?.stop()
    }
    
    // 暂停背景音乐
    func pause_background_music() {
        background_music_player?.pause()
    }
    
    // 恢复背景音乐
    func resume_background_music() {
        // 检查用户是否启用了背景音乐
        if !user_defaults.bool(forKey: background_music_key, defaultValue: true) {
            return
        }
        
        background_music_player?.play()
    }
    
    // 播放音效
    func play_sound_effect(name: String) {
        // 检查用户是否启用了音效
        if !user_defaults.bool(forKey: sound_effects_key, defaultValue: true) {
            return
        }
        
        guard let url = Bundle.main.url(forResource: name, withExtension: "mp3") else {
            return
        }
        
        do {
            sound_effect_player = try AVAudioPlayer(contentsOf: url)
            sound_effect_player?.play()
        } catch {
        }
    }
}

// 扩展UserDefaults以提供默认值
extension UserDefaults {
    func bool(forKey key: String, defaultValue: Bool) -> Bool {
        if object(forKey: key) == nil {
            set(defaultValue, forKey: key)
            return defaultValue
        }
        return bool(forKey: key)
    }
}
