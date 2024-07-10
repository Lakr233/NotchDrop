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
            Text("Notch Drop")
            Spacer()
            Text(verbatim: "888888888888888")
                .hidden()
                .overlay { github.buttonStyle(PlainButtonStyle()) }
        }
        .font(.system(.headline, design: .rounded))
    }

    @ViewBuilder
    var github: some View {
        if vm.openedSponsorPage {
            Button {
                NSWorkspace.shared.open(productPage)
            } label: {
                Image(.gitHub)
                    .antialiased(true)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }
        } else {
            Button {
                NSWorkspace.shared.open(sponsorPage)
                vm.openedSponsorPage = true
            } label: {
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
}

#Preview {
    NotchHeaderView(vm: .init())
}
