//
//  NotchHeaderView.swift
//  NotchDrop
//
//  Created by 秋星桥 on 2024/7/7.
//

import ColorfulX
import SwiftUI

struct NotchHeaderView: View {
    @StateObject var vm: NotchViewModel

    var body: some View {
        HStack {
            Text(NSLocalizedString("Notch Drop", comment: ""))
            Spacer()
            Text("888888888888888")
                .hidden()
                .overlay { github }
        }
        .font(.system(.headline, design: .rounded))
    }

    @ViewBuilder
    var github: some View {
        if vm.openedSponsorPage {
            Image(.gitHub)
                .antialiased(true)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(maxWidth: .infinity, alignment: .trailing)
        } else {
            ColorfulView(color: .constant(ColorfulPreset.appleIntelligence.colors))
                .contrast(2)
                .mask(
                    HStack {
                        Text("Donate")
                        Image(systemName: "arrow.up.right.circle.fill")
                    }
                    .frame(maxWidth: .infinity, alignment: .trailing)
                )
        }
    }
}

#Preview {
    NotchHeaderView(vm: .init())
}
