//
//  AirDrop.swift
//  NotchDrop
//
//  Created by 秋星桥 on 2024/7/7.
//

import Cocoa

class AirDrop: NSObject, NSSharingServiceDelegate {
    let files: [URL]

    init(files: [URL]) {
        self.files = files
        super.init()
    }

    func begin() {
        do {
            try sendEx(files)
        } catch {
            let alert = NSAlert()
            alert.messageText = "Error"
            alert.alertStyle = .critical
            alert.informativeText = error.localizedDescription
            alert.addButton(withTitle: "OK")
            alert.runModal()
        }
    }

    private func sendEx(_ files: [URL]) throws {
        guard let service = NSSharingService(named: .sendViaAirDrop) else {
            throw NSError(domain: "AirDrop", code: 1, userInfo: [NSLocalizedDescriptionKey: "AirDrop not available"])
        }
        guard service.canPerform(withItems: files) else {
            throw NSError(domain: "AirDrop", code: 2, userInfo: [NSLocalizedDescriptionKey: "Cannot send files"])
        }
        service.delegate = self
        service.perform(withItems: files)
    }
}
