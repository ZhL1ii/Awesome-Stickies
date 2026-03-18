//
//  SettingsView.swift
//  Awesome_Stickies
//
//  Created by Chie on 2026/3/17.
//

import SwiftUI

struct SettingsView: View {
    @ObservedObject var viewModel: AppViewModel

    var body: some View {
        Form {
            Section("Appearance") {
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Text("Window Opacity")
                        Spacer()
                        Text(opacityPercentageText)
                            .foregroundStyle(.secondary)
                            .monospacedDigit()
                    }

                    // Keep the control narrow in scope: one global value applied to all notes.
                    Slider(
                        value: viewModel.windowOpacityBinding(),
                        in: AppPreferences.minimumWindowOpacity...AppPreferences.maximumWindowOpacity
                    )

                    Text("Applies to every sticky window and is saved with your notes data.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
                .padding(.vertical, 4)
            }
        }
        .formStyle(.grouped)
        .padding(20)
        .frame(width: 420)
    }
}

private extension SettingsView {
    var opacityPercentageText: String {
        "\(Int(viewModel.windowOpacity * 100))%"
    }
}
