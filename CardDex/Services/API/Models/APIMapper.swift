//
//  APIMapper.swift
//  CardDex
//
//  Created by Martin Plut on 2/1/26.
//


import Foundation

enum APIMapper {
    
    // MARK: - Card Mapping
    static func mapToCard(from apiCard: CardAPIResponse, quantityOwned: Int = 1) -> Card {
        print("🗺️ Mapping card: \(apiCard.name)")
        
        // Determine supertype from category
        let supertype = apiCard.category ?? "Pokémon"
        print("  - Supertype: \(supertype)")
        
        // Map attacks
        let attacks = mapAttacks(from: apiCard.attacks)
        print("  - Attacks: \(attacks?.count ?? 0) attacks")
        if let attacks = attacks {
            for attack in attacks {
                print("    • \(attack.name): \(attack.displayDamage)")
            }
        }
        
        // Map ability (take first if multiple)
        let ability = mapAbility(from: apiCard.abilities?.first)
        print("  - Ability: \(ability?.name ?? "none")")
        
        // Map weaknesses and resistances
        let weaknesses = mapWeaknessResistances(from: apiCard.weaknesses)
        let resistances = mapWeaknessResistances(from: apiCard.resistances)
        print("  - Weaknesses: \(weaknesses?.count ?? 0)")
        print("  - Resistances: \(resistances?.count ?? 0)")
        
        // Build retreat cost array
        let retreatCost = apiCard.retreat != nil ? Array(repeating: "Colorless", count: apiCard.retreat!) : nil
        print("  - Retreat Cost: \(retreatCost?.count ?? 0)")
        
        // Fix image URLs - TCGdex requires /high.png or /low.png suffix
        let imageSmall = apiCard.image != nil ? "\(apiCard.image!)/low.webp" : nil
        let imageLarge = apiCard.image != nil ? "\(apiCard.image!)/high.webp" : nil
        print("  - Images: \(imageSmall != nil ? "✓" : "✗")")
        
        let card = Card(
            id: apiCard.id,
            name: apiCard.name,
            supertype: supertype,
            subtypes: apiCard.stage != nil ? [apiCard.stage!] : nil,
            hp: apiCard.hp != nil ? String(apiCard.hp!) : nil,
            types: apiCard.types,
            evolvesFrom: apiCard.evolveFrom,
            evolvesTo: nil, // TCGdex doesn't provide this
            retreatCost: retreatCost,
            attacks: attacks,
            ability: ability,
            weaknesses: weaknesses,
            resistances: resistances,
            effect: apiCard.effect != nil ? String(apiCard.effect!) : nil,
            trainerType: apiCard.trainerType != nil ? String(apiCard.trainerType!) : nil,
            setID: apiCard.set.id,
            setName: apiCard.set.name,
            setLogo: apiCard.set.logo,
            number: apiCard.localId,
            rarity: apiCard.rarity,
            imageSmall: imageSmall,
            imageLarge: imageLarge,
            artist: apiCard.illustrator,
            flavorText: apiCard.description,
            regulationMark: apiCard.regulationMark,
            quantityOwned: quantityOwned,
            dateAdded: Date()
        )
        
        print("✅ Card mapped successfully")
        return card
    }
    
    // MARK: - CardSet Mapping
    static func mapToCardSet(from apiSet: SetAPIResponse) -> CardSet {
        CardSet(
            id: apiSet.id,
            name: apiSet.name,
            series: apiSet.serie?.name ?? "Unknown",
            printedTotal: apiSet.cardCount.official,
            total: apiSet.cardCount.total ?? apiSet.cardCount.official,
            releaseDate: apiSet.releaseDate,
            updatedAt: nil,
            logoURL: apiSet.logo,
            symbolURL: apiSet.symbol
        )
    }
    
    static func mapToCardSet(from apiSet: SetBriefAPI) -> CardSet {
        CardSet(
            id: apiSet.id,
            name: apiSet.name,
            series: "Unknown",
            printedTotal: apiSet.cardCount?.official ?? 0,
            total: apiSet.cardCount?.total ?? apiSet.cardCount?.official ?? 0,
            releaseDate: "",
            updatedAt: nil,
            logoURL: apiSet.logo,
            symbolURL: apiSet.symbol
        )
    }
    
    // MARK: - Private Mapping Helpers
    private static func mapAttacks(from apiAttacks: [AttackAPI]?) -> [Attack]? {
        guard let apiAttacks = apiAttacks, !apiAttacks.isEmpty else { return nil }
        
        return apiAttacks.map { apiAttack in
            Attack(
                name: apiAttack.name,
                cost: apiAttack.cost,
                damage: apiAttack.damage,
                text: apiAttack.effect,
                convertedEnergyCost: apiAttack.cost?.count ?? 0
            )
        }
    }
    
    private static func mapAbility(from apiAbility: AbilityAPI?) -> Ability? {
        guard let apiAbility = apiAbility else { return nil }
        
        return Ability(
            name: apiAbility.name,
            text: apiAbility.effect,
            type: apiAbility.type ?? "Ability"
        )
    }
    
    private static func mapWeaknessResistances(from apiEffects: [WeaknessResistanceAPI]?) -> [TypeEffect]? {
        guard let apiEffects = apiEffects, !apiEffects.isEmpty else { return nil }
        
        return apiEffects.map { apiEffect in
            TypeEffect(
                type: apiEffect.type,
                value: apiEffect.value ?? "×2"
            )
        }
    }
}

// MARK: - Batch Mapping
extension APIMapper {
    static func mapToCards(from apiCards: [CardAPIResponse]) -> [Card] {
        apiCards.map { mapToCard(from: $0) }
    }
    
    static func mapToCardSets(from apiSets: [SetBriefAPI]) -> [CardSet] {
        apiSets.map { mapToCardSet(from: $0) }
    }
}
