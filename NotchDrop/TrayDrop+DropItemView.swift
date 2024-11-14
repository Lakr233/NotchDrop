//
//  TrayDrop+DropItemView.swift
//  NotchDrop
//
//  Created by 秋星桥 on 2024/7/8.
//

import Foundation
import Pow
import SwiftUI
import UniformTypeIdentifiers

struct DropItemView: View {
    let item: TrayDrop.DropItem
    @StateObject var vm: NotchViewModel
    @StateObject var tvm = TrayDrop.shared

    @State var hover = false

    var body: some View {
        VStack {
            Image(nsImage: item.workspacePreviewImage)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(maxWidth: 64)
            Text(item.fileName)
                .multilineTextAlignment(.center)
                .font(.system(.footnote, design: .rounded))
                .frame(maxWidth: 64)
        }
        .contentShape(Rectangle())
        .transition(.asymmetric(
            insertion: .opacity.combined(with: .scale),
            removal: .movingParts.poof
        ))
        .contentShape(Rectangle())
        .onHover { hover = $0 }
        .scaleEffect(hover ? 1.05 : 1.0)
        .animation(vm.animation, value: hover)
        .draggable(item)
        .onTapGesture {
            guard !vm.optionKeyPressed else { return }
            vm.notchClose()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                NSWorkspace.shared.open(item.storageURL)
            }
        }
        .overlay {
            Image(systemName: "xmark.circle.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .foregroundStyle(.red)
                .background(Color.white.clipShape(Circle()).padding(1))
                .frame(width: vm.spacing, height: vm.spacing)
                .opacity(vm.optionKeyPressed ? 1 : 0)
                .scaleEffect(vm.optionKeyPressed ? 1 : 0.5)
                .animation(vm.animation, value: vm.optionKeyPressed)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                .offset(x: vm.spacing / 2, y: -vm.spacing / 2)
                .onTapGesture { tvm.delete(item.id) }
        }
    }
}
