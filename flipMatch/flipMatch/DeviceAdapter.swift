
import UIKit

class DeviceAdapter {
    
    // MARK: - Singleton
    static let shared = DeviceAdapter()
    private init() {}
    
    // MARK: - Device Type Detection
    enum DeviceType {
        case iPhone
        case iPad
        case unknown
    }
    
    var current_device_type: DeviceType {
        let device = UIDevice.current
        if device.userInterfaceIdiom == .phone {
            return .iPhone
        } else if device.userInterfaceIdiom == .pad {
            return .iPad
        } else {
            return .unknown
        }
    }
    
    var is_ipad: Bool {
        return current_device_type == .iPad
    }
    
    // MARK: - Screen Size
    var screen_width: CGFloat {
        return UIScreen.main.bounds.width
    }
    
    var screen_height: CGFloat {
        return UIScreen.main.bounds.height
    }
    
    // MARK: - Safe Area
    func safe_area_insets() -> UIEdgeInsets {
        if #available(iOS 11.0, *) {
            let window = UIApplication.shared.windows.first
            return window?.safeAreaInsets ?? .zero
        }
        return .zero
    }
    
    // MARK: - Adaptive Sizing
    func adaptive_font_size(base_size: CGFloat) -> CGFloat {
        switch current_device_type {
        case .iPhone:
            return base_size
        case .iPad:
            return base_size * 1.3
        case .unknown:
            return base_size
        }
    }
    
    func adaptive_spacing(base_spacing: CGFloat) -> CGFloat {
        switch current_device_type {
        case .iPhone:
            return base_spacing
        case .iPad:
            return base_spacing * 1.5
        case .unknown:
            return base_spacing
        }
    }
    
    func adaptive_corner_radius(base_radius: CGFloat) -> CGFloat {
        switch current_device_type {
        case .iPhone:
            return base_radius
        case .iPad:
            return base_radius * 1.3
        case .unknown:
            return base_radius
        }
    }
    
    // MARK: - Layout Helpers
    func card_size(for_grid_size grid_size: CGSize, with_spacing spacing: CGFloat) -> CGSize {
        let max_width = screen_width - (2 * spacing)
        let max_height = screen_height - (2 * spacing)
        
        let columns = grid_size.width
        let rows = grid_size.height
        
        // Calculate card width and height based on available space and grid size
        let card_width = (max_width - (columns - 1) * spacing) / columns
        let card_height = (max_height - (rows - 1) * spacing) / rows
        
        // Use the smaller dimension to ensure square cards
        let card_size = min(card_width, card_height)
        
        return CGSize(width: card_size, height: card_size)
    }
    
    func grid_layout(for_grid_size grid_size: CGSize, with_spacing spacing: CGFloat) -> (card_size: CGSize, offset_x: CGFloat, offset_y: CGFloat) {
        let card_size = card_size(for_grid_size: grid_size, with_spacing: spacing)
        
        // Calculate total width and height of the grid
        let total_width = (card_size.width * grid_size.width) + (spacing * (grid_size.width - 1))
        let total_height = (card_size.height * grid_size.height) + (spacing * (grid_size.height - 1))
        
        // Calculate offsets to center the grid
        let offset_x = (screen_width - total_width) / 2
        let offset_y = (screen_height - total_height) / 2
        
        return (card_size, offset_x, offset_y)
    }
    
    // MARK: - Orientation Support
    func is_landscape() -> Bool {
        return UIDevice.current.orientation.isLandscape
    }
    
    func is_portrait() -> Bool {
        return UIDevice.current.orientation.isPortrait
    }
    
    // MARK: - Device Specific Adjustments
    func adjust_for_device<T>(iphone_value: T, ipad_value: T) -> T {
        switch current_device_type {
        case .iPhone:
            return iphone_value
        case .iPad:
            return ipad_value
        case .unknown:
            return iphone_value
        }
    }
    
    // MARK: - UI Element Sizing
    func button_size(base_width: CGFloat, base_height: CGFloat) -> CGSize {
        switch current_device_type {
        case .iPhone:
            return CGSize(width: base_width, height: base_height)
        case .iPad:
            return CGSize(width: base_width * 1.3, height: base_height * 1.3)
        case .unknown:
            return CGSize(width: base_width, height: base_height)
        }
    }
    
    func container_margin() -> CGFloat {
        switch current_device_type {
        case .iPhone:
            return 15
        case .iPad:
            return 30
        case .unknown:
            return 15
        }
    }
    
    func adaptive_height(base_height: CGFloat) -> CGFloat {
        switch current_device_type {
        case .iPhone:
            return base_height
        case .iPad:
            return base_height * 1.3
        case .unknown:
            return base_height
        }
    }
    
    // MARK: - Game Board Adjustments
    func game_board_size(for_mode mode: GameMode) -> CGSize {
        switch mode {
        case .normal, .challenge:
            return adjust_for_device(
                iphone_value: CGSize(width: 9, height: 12),
                ipad_value: CGSize(width: 9, height: 12)
            )
        case .easy:
            return adjust_for_device(
                iphone_value: CGSize(width: 6, height: 4),
                ipad_value: CGSize(width: 6, height: 4)
            )
        }
    }
    
    func game_board_spacing() -> CGFloat {
        return adjust_for_device(iphone_value: 2.0, ipad_value: 4.0)
    }
}
