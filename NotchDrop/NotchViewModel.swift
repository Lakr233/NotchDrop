import Cocoa
import Combine
import Foundation
import SwiftUI
import LaunchAtLogin

class NotchViewModel: NSObject, ObservableObject {
    var cancellables: Set<AnyCancellable> = []
    let inset: CGFloat
    
    @Published var selectedLanguage: Language = .system {
        didSet {
            UserDefaults.standard.set(selectedLanguage.rawValue, forKey: "selectedLanguage")
            applyLanguage()
        }
    }
    
    @Published var selectedFileStorageTime: FileStorageTime = .oneDay {
        didSet {
            UserDefaults.standard.set(selectedFileStorageTime.rawValue, forKey: "selectedFileStorageTime")
            updateKeepInterval()
        }
    }
    @Published var customStorageTime: Int = 1 {
        didSet {
            UserDefaults.standard.set(customStorageTime, forKey: "customStorageTime")
            updateKeepInterval()
        }
    }
    @Published var customStorageTimeUnit: CustomstorageTimeUnit = .days {
        didSet {
            UserDefaults.standard.set(customStorageTimeUnit.rawValue, forKey: "customStorageTimeUnit")
            updateKeepInterval()
        }
    }
    
    init(inset: CGFloat = -4) {
        self.inset = inset
        super.init()
        setupCancellables()
        loadSettings()
    }
    
    deinit {
        destroy()
    }
    
    let animation: Animation = .interactiveSpring(
        duration: 0.5,
        extraBounce: 0.25,
        blendDuration: 0.125
    )
    let notchOpenedSize: CGSize = .init(width: 600, height: 150)
    let dropDetectorRange: CGFloat = 32
    
    enum Status: String, Codable, Hashable, Equatable {
        case closed
        case opened
        case popping
    }
    
    enum OpenReason: String, Codable, Hashable, Equatable {
        case click
        case drag
        case boot
        case unknown
    }
    
    enum ContentType: Int, Codable, Hashable, Equatable {
        case normal
        case menu
        case settings
    }
    
    var notchOpenedRect: CGRect {
        .init(
            x: screenRect.origin.x + (screenRect.width - notchOpenedSize.width) / 2,
            y: screenRect.origin.y + screenRect.height - notchOpenedSize.height,
            width: notchOpenedSize.width,
            height: notchOpenedSize.height
        )
    }
    
    var headlineOpenedRect: CGRect {
        .init(
            x: screenRect.origin.x + (screenRect.width - notchOpenedSize.width) / 2,
            y: screenRect.origin.y + screenRect.height - deviceNotchRect.height,
            width: notchOpenedSize.width,
            height: deviceNotchRect.height
        )
    }
    
    @Published private(set) var status: Status = .closed
    @Published var openReason: OpenReason = .unknown
    @Published var contentType: ContentType = .normal
    
    @Published var spacing: CGFloat = 16
    @Published var cornerRadius: CGFloat = 16
    @Published var deviceNotchRect: CGRect = .zero
    @Published var screenRect: CGRect = .zero
    @Published var optionKeyPressed: Bool = false
    @Published var notchVisible: Bool = true
    
    @PublishedPersist(key: "OpenedSponsorPage", defaultValue: false)
    var openedSponsorPage: Bool
    
    func notchOpen(_ reason: OpenReason) {
        openReason = reason
        status = .opened
        contentType = .normal
    }
    
    func notchClose() {
        openReason = .unknown
        status = .closed
        contentType = .normal
    }
    
    func showSettings() {
        contentType = .settings
    }
    
    func notchPop() {
        openReason = .unknown
        status = .popping
    }
    
    enum Language: String, CaseIterable, Identifiable {
        case system = "Follow System"
        case english = "English"
        case simplifiedChinese = "Simplified Chinese"
        case traditionalChinese = "Traditional Chinese"
        
        var id: String { self.rawValue }
        
        var localized: String {
            return NSLocalizedString(self.rawValue, comment: "")
        }
    }
    
    enum FileStorageTime: String, CaseIterable, Identifiable {
        case oneDay = "1 Day"
        case twoDays = "2 Days"
        case threeDays = "3 Days"
        case oneWeek = "1 Week"
        case never = "Forever"
        case custom = "Custom"
        
        var id: String { self.rawValue }
        
        var localized: String {
            return NSLocalizedString(self.rawValue, comment: "")
        }
        
        func toTimeInterval(customTime: TimeInterval) -> TimeInterval {
            switch self {
            case .oneDay:
                return 60 * 60 * 24
            case .twoDays:
                return 60 * 60 * 24 * 2
            case .threeDays:
                return 60 * 60 * 24 * 3
            case .oneWeek:
                return 60 * 60 * 24 * 7
            case .never:
                return TimeInterval.infinity
            case .custom:
                return customTime
            }
        }
    }
    
    enum CustomstorageTimeUnit: String, CaseIterable, Identifiable {
        case days = "Days"
        case weeks = "Weeks"
        case months = "Months"
        case years = "Years"
        
        var id: String { self.rawValue }
        
        var localized: String {
            return NSLocalizedString(self.rawValue, comment: "")
        }
    }
    
    func loadSettings() {
        if let savedLanguage = UserDefaults.standard.string(forKey: "selectedLanguage"),
           let language = Language(rawValue: savedLanguage) {
            self.selectedLanguage = language
        } else {
            self.selectedLanguage = .system
        }
        
        if let savedFileStorageTime = UserDefaults.standard.string(forKey: "selectedFileStorageTime"),
           let fileStorageTime = FileStorageTime(rawValue: savedFileStorageTime) {
            self.selectedFileStorageTime = fileStorageTime
        } else {
            self.selectedFileStorageTime = .oneDay
        }
        
        self.customStorageTime = UserDefaults.standard.integer(forKey: "customStorageTime")
        
        if let savedCustomStorageTimeUnit = UserDefaults.standard.string(forKey: "customStorageTimeUnit"),
           let customStorageTimeUnit = CustomstorageTimeUnit(rawValue: savedCustomStorageTimeUnit) {
            self.customStorageTimeUnit = customStorageTimeUnit
        } else {
            self.customStorageTimeUnit = .days
        }
        
        applyLanguage()
        updateKeepInterval()
    }
    
    func updateKeepInterval() {
        let customTime: TimeInterval = {
            switch customStorageTimeUnit {
            case .days:
                return TimeInterval(customStorageTime) * 60 * 60 * 24
            case .weeks:
                return TimeInterval(customStorageTime) * 60 * 60 * 24 * 7
            case .months:
                return TimeInterval(customStorageTime) * 60 * 60 * 24 * 30
            case .years:
                return TimeInterval(customStorageTime) * 60 * 60 * 24 * 365
            }
        }()

        TrayDrop.keepInterval = selectedFileStorageTime.toTimeInterval(customTime: customTime)
//        print("Updated keepInterval to: \(TrayDrop.keepInterval)")
    }
    
    var count = 0
    
    func applyLanguage() {
        count += 1
        let languageCode: String?
        
        let local = Calendar.autoupdatingCurrent.locale?.identifier

        // Extract the part after '@' if it exists, otherwise the part after '_'
        let region = local?.split(separator: "@").last?.split(separator: "_").last

//        print("region: \(region ?? "none")")

        switch selectedLanguage {
        case .system:
            if region == "rg=hkzzzz" || region == "rg=twzzzz" || region == "rg=mozzzz"
            || region == "TW" || region == "HK" || region == "MO"
            {
                languageCode = "zh-Hant"
            } else if region == "CN" {
                languageCode = "zh-Hans"
            } else {
                languageCode = "en"
            }
//            print("system: \(languageCode ?? "none")")
        case .english:
            languageCode = "en"
        case .simplifiedChinese:
            languageCode = "zh-Hans"
        case .traditionalChinese:
            languageCode = "zh-Hant"
        }
//        print("Applying Language: \(languageCode ?? "none")") // Debug print to verify language being set
        Bundle.setLanguage(languageCode)
        
        // Show alert and restart app
        if count > 2 {
            NSAlert.popRestart(NSLocalizedString("The language has been changed. The app will restart for the changes to take effect.", comment: ""), completion: restartApp)
        }
    }
}


    // Terminate the app

func restartApp() {
    // Get the path to the app's executable
    guard let appPath = Bundle.main.executablePath else {
        return
    }

    // Terminate the app
    NSApp.terminate(nil)

    // Delay to ensure termination completes
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
        // Relaunch the app
        let process = Process()
        process.executableURL = URL(fileURLWithPath: appPath)
        do {
            try process.run()
        } catch {
            print("Failed to restart the app: \(error)")
        }
    }
}

extension Bundle {
    private static var onLanguageDispatchOnce: () -> Void = {
        object_setClass(Bundle.main, PrivateBundle.self)
    }
    
    static func setLanguage(_ language: String?) {
        onLanguageDispatchOnce()
        
        if let language = language {
            UserDefaults.standard.set([language], forKey: "AppleLanguages")
        } else {
            UserDefaults.standard.removeObject(forKey: "AppleLanguages")
        }
        UserDefaults.standard.synchronize()
    }
}



private class PrivateBundle: Bundle {
    override func localizedString(forKey key: String, value: String?, table tableName: String?) -> String {
        guard let languages = UserDefaults.standard.array(forKey: "AppleLanguages") as? [String],
              let languageCode = languages.first,
              let bundlePath = Bundle.main.path(forResource: languageCode, ofType: "lproj"),
              let bundle = Bundle(path: bundlePath) else {
            return super.localizedString(forKey: key, value: value, table: tableName)
        }
        return bundle.localizedString(forKey: key, value: value, table: tableName)
    }
}
