//
//  NotchViewModel+Events.swift
//  NotchDrop
//
//  Created by 秋星桥 on 2024/7/8.
//

import Cocoa
import Combine
import Foundation

extension NotchViewModel {
    func setupCancellables() {
        let events = EventMonitors.shared
        events.mouseDown
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let self else { return }
                let mouseLocation: NSPoint = NSEvent.mouseLocation
                switch status {
                case .opened:
                    // touch outside, close
                    if !notchOpenedRect.contains(mouseLocation) {
                        notchClose()
                        // click where user open the panel
                    } else if deviceNotchRect.contains(mouseLocation) {
                        notchClose()
                        // for the same height as device notch, open the url of project
                    } else {
                        var checkRect = deviceNotchRect
                        checkRect.origin.x = 0
                        checkRect.size.width = screenRect.width
                        if checkRect.contains(mouseLocation) {
                            notchClose()
                            NSWorkspace.shared.open(productPage)
                        }
                    }
                case .closed, .popping:
                    // touch inside, open
                    if deviceNotchRect.contains(mouseLocation) {
                        notchOpen(.click)
                    }
                }
            }
            .store(in: &cancellables)

        events.mouseUp
            .delay(for: 0.1, scheduler: DispatchQueue.main)
            .sink {
                let pasteboard = NSPasteboard(name: .drag)
                pasteboard.prepareForNewContents()
                pasteboard.writeObjects([])
            }
            .store(in: &cancellables)

        events.optionKeyPress
            .receive(on: DispatchQueue.main)
            .sink { [weak self] input in
                guard let self else { return }
                optionKeyPressed = input
            }
            .store(in: &cancellables)

        events.mouseLocation
            .receive(on: DispatchQueue.main)
            .sink { [weak self] mouseLocation in
                guard let self else { return }
                let mouseLocation: NSPoint = NSEvent.mouseLocation
                let aboutToOpen = deviceNotchRect.contains(mouseLocation)
                if status == .closed, aboutToOpen { notchPop() }
                if status == .popping, !aboutToOpen { notchClose() }
            }
            .store(in: &cancellables)
//
        Publishers.CombineLatest(
            events.mouseLocation,
            events.mouseDraggingFile
        )
        .receive(on: DispatchQueue.main)
        .map { _, _ in
            let location: NSPoint = NSEvent.mouseLocation
            let draggingFile = NSPasteboard(name: .drag)
                .pasteboardItems ?? []
            return (location, draggingFile)
        }
        .sink { [weak self] location, draggingFile in
            guard let self else { return }
            switch status {
            case .opened:
                guard openedBy == .drag else { return }
                if deviceNotchRect.insetBy(dx: -14, dy: -14).contains(location) {
                    break
                }
                if !notchOpenedRect.insetBy(dx: -32, dy: -32).contains(location) {
                    if status == .opened { notchClose() }
                }
            case .closed, .popping:
                guard !draggingFile.isEmpty else { return }
                if deviceNotchRect.insetBy(dx: -14, dy: -14).contains(location) {
                    notchOpen(.drag)
                }
            }
        }
        .store(in: &cancellables)

        $status
            .filter { $0 != .closed }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in self?.notchVisible = true }
            .store(in: &cancellables)

        $status
            .sink { _ in
                NSHapticFeedbackManager.defaultPerformer.perform(
                    .alignment,
                    performanceTime: .now
                )
            }
            .store(in: &cancellables)

        $status
            .debounce(for: 0.5, scheduler: DispatchQueue.global())
            .filter { $0 == .closed }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in self?.notchVisible = false }
            .store(in: &cancellables)
    }

    func destroy() {
        cancellables.forEach { $0.cancel() }
        cancellables.removeAll()
    }
}
