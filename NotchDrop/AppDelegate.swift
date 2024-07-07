//
//  AppDelegate.swift
//  NotchDrop
//
//  Created by 秋星桥 on 2024/7/7.
//

import AppKit
import Cocoa

class AppDelegate: NSObject, NSApplicationDelegate {
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
        if let mainWindowController {
            mainWindowController.close()
        }
        mainWindowController = nil
        guard let mainScreen = NSScreen.buildin, mainScreen.notchSize != .zero else {
            return
        }
        print("[i] screen \(mainScreen) has notch with size \(mainScreen.notchSize)")
        mainWindowController = .init(screen: mainScreen)
    }
}
