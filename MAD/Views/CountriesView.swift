//
//  CountriesView.swift
//  MAD
//
//  Created by Fabian Gerö on 05.11.26.
//


import SwiftUI

struct CountriesView: View {
    let networkingService: NetworkingService
    let user: User

    @State private var countries: [Country]?
    @State private var isLoading = false
    @State private var errorMessage: String?

    var body: some View {
        content
            .navigationTitle("Countries")
            .onAppear(perform: loadCountriesIfNeeded)
    }

    @ViewBuilder
    private var content: some View {
        if let countries {
            List(countries, id: \.ID) { country in
                NavigationLink {
                    CountryDetailView(country: country)
                } label: {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(country.name)

                        if country.native != country.name {
                            Text(country.native)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
        } else if let errorMessage {
            ContentUnavailableView {
                Label("Couldn't load countries", systemImage: "exclamationmark.triangle")
            } description: {
                Text(errorMessage)
            } actions: {
                Button("Try Again", action: loadCountries)
            }
        } else {
            ProgressView("Loading countries…")
        }
    }

    private func loadCountriesIfNeeded() {
        guard countries == nil else { return }
        loadCountries()
    }

    private func loadCountries() {
        guard !isLoading else { return }

        isLoading = true
        errorMessage = nil

        networkingService.fetchCountries(for: user) { loadedCountries, error in
            isLoading = false

            if let loadedCountries {
                countries = loadedCountries
            } else if let error {
                errorMessage = error.message
            }
        }
    }
}