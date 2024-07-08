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

    override init() {
        super.init()
        print("[+] AppDelegate init")
    }

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
                alert.messageText = "Error"
                alert.alertStyle = .critical
                alert.informativeText = "You dont have a notch screen"
                alert.addButton(withTitle: "OK")
                alert.runModal()
            }
            return
        }
        print("[i] screen \(mainScreen) has notch with size \(mainScreen.notchSize)")
        mainWindowController = .init(screen: mainScreen)
    }
}
