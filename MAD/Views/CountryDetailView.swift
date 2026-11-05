//
//  CountryDetailView.swift
//  MAD
//
//  Created by Fabian Gerö on 05.11.26.
//


import SwiftUI

struct CountryDetailView: View {
    let country: Country

    var body: some View {
        List {
            Section("Details") {
                LabeledContent("Native name", value: displayValue(country.native))
                LabeledContent("Capital", value: displayValue(country.capital))
                LabeledContent("Continent", value: displayValue(country.continent))
                LabeledContent("Currency", value: displayValue(country.currency))
                LabeledContent("Calling code", value: displayValue(country.phone))
            }

            Section("Languages") {
                if country.languages.isEmpty {
                    Text("None")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(country.languages, id: \.self) { language in
                        Text(language)
                    }
                }
            }

            Section("Metadata") {
                LabeledContent("ID", value: country.ID)
                LabeledContent("Created", value: country.createTime, format: .dateTime)
                LabeledContent("Updated", value: country.updateTime, format: .dateTime)
            }
        }
        .navigationTitle(country.name)
    }

    private func displayValue(_ value: String) -> String {
        value.isEmpty ? "None" : value
    }
}

#Preview {
    NavigationStack {
        CountryDetailView(
            country: Country(
                ID: "oAgZVEWEOoJKdlNvYTSa",
                name: "Austria",
                currency: "EUR",
                capital: "Vienna",
                native: "Österreich",
                continent: "EU",
                phone: "43",
                createTime: .now,
                updateTime: .now,
                languages: ["de"]
            )
        )
    }
}