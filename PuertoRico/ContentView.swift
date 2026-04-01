//
//  ContentView.swift
//  PuertoRico
//
//  Created by Christoph Freier on 30.03.26.
//

import SwiftUI

struct ContentView: View {

    @State private var viewModel = BuildingViewModel()

    var body: some View {
        VStack(spacing: 20) {

            Text("Drawn Buildings")
                .font(.title)

            VStack(alignment: .leading) {
                Text("Include:")
                    .font(.headline)

                ForEach(GameType.allCases, id: \.self) { game in
                    Toggle(game.displayName,
                           isOn: Binding(
                            get: { viewModel.selectedGames.contains(game) },
                            set: { isOn in
                                if isOn {
                                    viewModel.selectedGames.insert(game)
                                } else {
                                    viewModel.selectedGames.remove(game)
                                }
                            }
                           )
                    )
                }
            }

            ScrollView {
                Text(viewModel.outputText)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
            }

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
