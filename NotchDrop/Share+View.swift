//
//  Share+View.swift
//  NotchDrop
//
//  Created by 秋星桥 on 2024/7/8.
//  Last Modified by 冷月 on 2025/5/5.
//

import ColorfulX
import Pow
import SwiftUI
import UniformTypeIdentifiers

struct ShareView: View {
    enum ShareType {
        case airdrop
        case generic

        var imageName: String {
            switch self {
            case .airdrop: return "airplayaudio"
            case .generic: return "arrow.up.circle"
            }
        }

        var title: String {
            switch self {
            case .airdrop: return NSLocalizedString("AirDrop", comment: "AirDrop sharing title")
            case .generic: return NSLocalizedString("Share", comment: "Generic sharing title")
            }
        }

        var service: ( [URL] ) -> Share {
            switch self {
            case .airdrop:
                return { urls in Share(files: urls, serviceName: .sendViaAirDrop) }
            case .generic:
                return { urls in Share(files: urls) }
            }
        }

        var colorfulPresetTargeting: ColorfulPreset {
            switch self {
            case .airdrop: return .neon
            case .generic: return .sunset
            }
        }

        var colorfulPresetNormal: ColorfulPreset {
            switch self {
            case .airdrop: return .aurora
            case .generic: return .sunrise
            }
        }
    }

    @StateObject var vm: NotchViewModel
    let type: ShareType

    @State var trigger: UUID = .init()
    @State var targeting = false

    var body: some View {
        dropArea
            .onDrop(of: [.data], isTargeted: $targeting) { providers in
                trigger = .init()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                    vm.notchClose()
                }
                DispatchQueue.global().async { beginDrop(providers) }
                return true
            }
    }

    var dropArea: some View {
        ColorfulView(
            color: .init(get: {
                if targeting {
                    type.colorfulPresetTargeting.colors
                } else {
                    type.colorfulPresetNormal.colors
                }
            }, set: { _ in }),
            speed: .init(get: {
                targeting ? 1.5 : 0
            }, set: { _ in }),
            transitionSpeed: .constant(25)
        )
        .opacity(0.5)
        .clipShape(RoundedRectangle(cornerRadius: vm.cornerRadius))
        .overlay { dropLabel }
        .aspectRatio(1, contentMode: .fit)
        .contentShape(Rectangle())
        .changeEffect(
            .spray(origin: UnitPoint(x: 0.5, y: 0.5)) {
                Image(systemName: "paperplane")
                    .foregroundStyle(.white)
            },
            value: trigger
        )
    }

    var dropLabel: some View {
        VStack(spacing: 8) {
            Image(systemName: type.imageName)
            Text(type.title)
        }
        .font(.system(.headline, design: .rounded))
        .contentShape(Rectangle())
        .onTapGesture {
            trigger = .init()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                vm.notchClose()
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                let picker = NSOpenPanel()
                picker.allowsMultipleSelection = true
                picker.canChooseDirectories = true
                picker.canChooseFiles = true
                picker.begin { response in
                    if response == .OK {
                        let drop = type.service(picker.urls)
                        drop.begin()
                    }
                }
            }
        }
    }

    func beginDrop(_ providers: [NSItemProvider]) {
        assert(!Thread.isMainThread)
        guard let urls = providers.interfaceConvert() else { return }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            let drop = type.service(urls)
            drop.begin()
        }
    }
}
