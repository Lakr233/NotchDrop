//
//  main.swift
//  NotchDrop
//
//  Created by 秋星桥 on 2024/7/7.
//

import AppKit

let productPage = URL(string: "https://github.com/Lakr233/NotchDrop")!

func print(_ items: Any..., separator: String = " ", terminator: String = "\n") {
    #if DEBUG
        let output = items
            .map { "\($0)" }
            .joined(separator: separator)
            + terminator
        NSLog(output)
    #endif
}

let bundleIdentifier = Bundle.main.bundleIdentifier!
let appVersion = "\(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "") (\(Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? ""))"

print("[*] Notch Drop")
print("    \(bundleIdentifier)")
print("    \(appVersion)")

private let availableDirectories = FileManager
    .default
    .urls(for: .documentDirectory, in: .userDomainMask)
let documentsDirectory = availableDirectories[0]
    .appendingPathComponent("NotchDrop")

try? FileManager.default.createDirectory(
    at: documentsDirectory,
    withIntermediateDirectories: true,
    attributes: nil
)

print("Document Dir: \(documentsDirectory.path)")

let temporaryDirectory = URL(fileURLWithPath: NSTemporaryDirectory())
    .appendingPathComponent(bundleIdentifier)
try? FileManager.default.removeItem(at: temporaryDirectory)
try? FileManager.default.createDirectory(
    at: documentsDirectory,
    withIntermediateDirectories: true,
    attributes: nil
)

print("Temp Dir: \(temporaryDirectory.path)")

_ = TrayDrop.shared

private let delegate = AppDelegate()
NSApplication.shared.delegate = delegate
_ = NSApplicationMain(CommandLine.argc, CommandLine.unsafeArgv)
