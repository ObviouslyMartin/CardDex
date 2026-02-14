//
//  CardDexApp.swift
//  CardDex
//
//  Created by Martin Plut on 2/1/26.
//

import SwiftUI
import SwiftData

@main
struct CardDexApp: App {
    
    let modelContainer: ModelContainer
    
    init() {
        do {
            // Configure model container
            let schema = Schema([
                Card.self,
                CardSet.self,
                Deck.self,
                DeckCard.self,
                BasicEnergy.self
            ])
            
            let modelConfiguration = ModelConfiguration(
                schema: schema,
                isStoredInMemoryOnly: false,
                allowsSave: true
            )
            
            modelContainer = try ModelContainer(
                for: schema,
                configurations: [modelConfiguration]
            )
            
            // Check if we need to migrate from old schema
            checkAndMigrateIfNeeded()
            
        } catch {
            fatalError("Failed to initialize model container: \(error)")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(modelContainer)
    }
    
    /// Check if old schema exists and needs migration
    private func checkAndMigrateIfNeeded() {
        let userDefaults = UserDefaults.standard
        let migrationKey = "hasCompletedDataModelMigration_v2"
        
        // If we haven't migrated yet, clear the old data
        if !userDefaults.bool(forKey: migrationKey) {
            print("🔄 Detected old data model. Clearing database for migration...")
            
            // Delete all existing data
            let context = modelContainer.mainContext
            
            do {
                // Delete all cards
                try context.delete(model: Card.self)
                // Delete all sets
                try context.delete(model: CardSet.self)
                // Delete all decks
                try context.delete(model: Deck.self)
                // Delete all deck cards
                try context.delete(model: DeckCard.self)
                
                try context.save()
                
                // Mark migration as complete
                userDefaults.set(true, forKey: migrationKey)
                
                print("✅ Database migration complete!")
            } catch {
                print("❌ Migration failed: \(error)")
            }
        }
    }
}
