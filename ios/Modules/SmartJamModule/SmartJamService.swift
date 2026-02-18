import Foundation

/// Pure selection service that chooses a SmartJamConfig from a catalog.
struct SmartJamService {
    var catalog: SmartJamPatternCatalog

    init(catalog: SmartJamPatternCatalog = .v1Catalog()) {
        self.catalog = catalog
    }

    func makeConfig(
        targetKey: String?,
        targetBPM: Int?,
        preferredStyles: [MusicStyle],
        category: SmartJamCategory
    ) -> SmartJamConfig? {
        let familiesForCategory = catalog.families.filter { $0.category == category }
        guard !familiesForCategory.isEmpty else { return nil }

        let preferredJamStyles = preferredStyles.compactMap { SmartJamStyle(musicStyle: $0) }
        let styleOrder = preferredJamStyles.isEmpty ? SmartJamStyle.defaultPreferenceOrder : preferredJamStyles

        let filteredByStyle: [SmartJamPatternFamily]
        if let chosenStyle = styleOrder.first(where: { style in
            familiesForCategory.contains(where: { $0.style == style })
        }) {
            filteredByStyle = familiesForCategory.filter { $0.style == chosenStyle }
        } else {
            filteredByStyle = familiesForCategory
        }

        guard let selectedFamily = filteredByStyle.sorted(by: { lhs, rhs in
            let lhsKeyScore = keyScore(family: lhs, targetKey: targetKey)
            let rhsKeyScore = keyScore(family: rhs, targetKey: targetKey)
            if lhsKeyScore != rhsKeyScore { return lhsKeyScore < rhsKeyScore }

            if let targetBPM {
                let lhsDelta = abs(lhs.baseBPM - targetBPM)
                let rhsDelta = abs(rhs.baseBPM - targetBPM)
                if lhsDelta != rhsDelta { return lhsDelta < rhsDelta }
            }

            if lhs.baseBPM != rhs.baseBPM { return lhs.baseBPM < rhs.baseBPM }
            return lhs.id < rhs.id
        }).first else {
            return nil
        }

        return SmartJamConfig(
            familyID: selectedFamily.id,
            assetName: selectedFamily.assetName,
            targetKey: targetKey ?? selectedFamily.baseKey,
            targetBPM: targetBPM ?? selectedFamily.baseBPM,
            baseBPM: selectedFamily.baseBPM,
            style: selectedFamily.style,
            category: selectedFamily.category
        )
    }

    private func keyScore(family: SmartJamPatternFamily, targetKey: String?) -> Int {
        guard let targetKey else { return 1 }
        guard let familyKey = family.baseKey else { return 2 }
        return familyKey.compare(targetKey, options: .caseInsensitive) == .orderedSame ? 0 : 1
    }
}
