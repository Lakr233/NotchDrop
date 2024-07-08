//
//  NotchViewModel.swift
//  NotchDrop
//
//  Created by 秋星桥 on 2024/7/7.
//

import Cocoa
import Combine
import Foundation
import SwiftUI

class NotchViewModel: NSObject, ObservableObject {
    var cancellables: Set<AnyCancellable> = []

    override init() {
        super.init()

        setupCancellables()
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

    enum Status {
        case closed
        case opened
        case popping
    }

    enum OpenedBy {
        case click
        case drag
        case boot
        case unknown
    }

    var openedBy: OpenedBy = .unknown

    var notchOpenedRect: CGRect {
        .init(
            x: screenRect.width / 2 - notchOpenedSize.width / 2,
            y: screenRect.height - notchOpenedSize.height,
            width: notchOpenedSize.width,
            height: notchOpenedSize.height
        )
    }

    @Published private(set) var status: Status = .closed
    @Published var spacing: CGFloat = 16
    @Published var cornerRadius: CGFloat = 16
    @Published var deviceNotchRect: CGRect = .zero
    @Published var screenRect: CGRect = .zero
    @Published var optionKeyPressed: Bool = false
    @Published var notchVisible: Bool = true

    func notchOpen(_ by: OpenedBy) {
        openedBy = by
        status = .opened
    }

    func notchClose() {
        openedBy = .unknown
        status = .closed
    }

    func notchPop() {
        openedBy = .unknown
        status = .popping
    }
}
