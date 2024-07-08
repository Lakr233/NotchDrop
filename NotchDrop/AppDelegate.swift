//
//  AppDelegate.swift
//  NotchDrop
//
//  Created by 秋星桥 on 2024/7/7.
//

import AppKit
import Cocoa

class AppDelegate: NSObject, NSApplicationDelegate {
    var isFirstOpen = true
    var mainWindowController: NotchWindowController?

    func applicationDidFinishLaunching(_: Notification) {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(rebuildApplicationWindows),
            name: NSApplication.didChangeScreenParametersNotification,
            object: nil
        )
        NSApp.setActivationPolicy(.accessory)

        _ = EventMonitors.shared

        rebuildApplicationWindows()
    }

    @objc func rebuildApplicationWindows() {
        defer { isFirstOpen = false }
        if let mainWindowController {
            mainWindowController.destroy()
        }
        mainWindowController = nil
        guard let mainScreen = NSScreen.buildin, mainScreen.notchSize != .zero else {
            if isFirstOpen {
                let alert = NSAlert()
                alert.messageText = NSLocalizedString("Error", comment: "")
                alert.alertStyle = .critical
                alert.informativeText = NSLocalizedString("Your current screen does not have a notch", comment: "")
                alert.addButton(withTitle: NSLocalizedString("OK", comment: ""))
                alert.runModal()
            }
            return
        }
        mainWindowController = .init(screen: mainScreen)
    }
}
