//
//  ContentView.swift
//  PuertoRico
//
//  Created by Christoph Freier on 30.03.26.
//

import SwiftUI

struct ContentView: View {

    @State private var viewModel = BuildingViewModel()

    struct iOSCheckboxToggleStyle: ToggleStyle {
        func makeBody(configuration: Configuration) -> some View {

            Button(action: {
                configuration.isOn.toggle()
            }, label: {
                HStack {
                    Image(systemName: configuration.isOn ? "checkmark.square" : "square")
                    configuration.label
                }
            })
        }
    }

    private func label(for game: GameType) -> String {
        switch game {
        case .exp: return "Expanded Buildings"
        case .cit: return "Citizen Buildings"
        default: return game.rawValue.capitalized
        }
    }

    var body: some View {
        VStack(spacing: 20) {

            Text("Drawn Buildings")
                .font(.title)

            VStack(alignment: .leading) {
                Text("Include:")
                    .font(.headline)

                ForEach([GameType.exp, GameType.cit], id: \.self) { game in
                    Toggle(label(for: game), isOn: Binding(
                        get: { viewModel.selectedGames.contains(game) },
                        set: { isOn in
                            if isOn { viewModel.selectedGames.insert(game) }
                            else { viewModel.selectedGames.remove(game) }
                        }
                    ))
                }
            }
            .toggleStyle(iOSCheckboxToggleStyle())
            .frame(maxWidth: .infinity, alignment: .leading)

            ScrollView {
                Text(viewModel.outputText)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Button("Redraw") {
                viewModel.draw()
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
