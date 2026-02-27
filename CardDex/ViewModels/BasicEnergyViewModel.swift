//
//  BasicEnergyViewModel.swift
//  CardDex
//
//  Created by Martin Plut on 2/8/26.
//

import Foundation
import SwiftData

@MainActor
@Observable
final class BasicEnergyViewModel {
    
    private let modelContext: ModelContext
    var energies: [BasicEnergy] = []
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        fetchEnergies()
        initializeEnergiesIfNeeded()
    }
    
    // MARK: - Fetch Operations
    func fetchEnergies() {
        let descriptor = FetchDescriptor<BasicEnergy>(
            sortBy: [SortDescriptor(\.type)]
        )
        
        do {
            energies = try modelContext.fetch(descriptor)
        } catch {
            print("Error fetching basic energies: \(error)")
            energies = []
        }
    }
    
    // MARK: - Initialize
    
    /// Creates entries for all energy types if they don't exist
    private func initializeEnergiesIfNeeded() {
        for type in BasicEnergy.allTypes {
            if !energyExists(type: type) {
                let energy = BasicEnergy(type: type, count: 0)
                modelContext.insert(energy)
            }
        }
        
        try? modelContext.save()
        fetchEnergies()
    }
    
    private func energyExists(type: String) -> Bool {
        let descriptor = FetchDescriptor<BasicEnergy>(
            predicate: #Predicate { $0.type == type }
        )
        
        do {
            let results = try modelContext.fetch(descriptor)
            return !results.isEmpty
        } catch {
            return false
        }
    }
    
    // MARK: - Update Operations
    
    func updateCount(for type: String, count: Int) {
        guard let energy = energies.first(where: { $0.type == type }) else { return }
        
        energy.count = max(0, count) // Prevent negative counts
        energy.dateModified = Date()
        
        try? modelContext.save()
        fetchEnergies()
        
        HapticFeedback.light()
    }
    
    func increment(type: String, by amount: Int = 1) {
        guard let energy = energies.first(where: { $0.type == type }) else { return }
        
        energy.count += amount
        energy.dateModified = Date()
        
        try? modelContext.save()
        fetchEnergies()
        
        HapticFeedback.light()
    }
    
    func decrement(type: String, by amount: Int = 1) {
        guard let energy = energies.first(where: { $0.type == type }) else { return }
        
        energy.count = max(0, energy.count - amount)
        energy.dateModified = Date()
        
        try? modelContext.save()
        fetchEnergies()
        
        HapticFeedback.light()
    }
    
    func reset(type: String) {
        guard let energy = energies.first(where: { $0.type == type }) else { return }
        
        energy.count = 0
        energy.dateModified = Date()
        
        try? modelContext.save()
        fetchEnergies()
        
        HapticFeedback.warning()
    }
    
    func resetAll() {
        for energy in energies {
            energy.count = 0
            energy.dateModified = Date()
        }
        
        try? modelContext.save()
        fetchEnergies()
        
        HapticFeedback.warning()
    }
    
    // MARK: - Statistics
    
    var totalEnergyCount: Int {
        energies.reduce(0) { $0 + $1.count }
    }
    
    var energyTypesOwned: Int {
        energies.filter { $0.count > 0 }.count
    }
    
    func getCount(for type: String) -> Int {
        energies.first(where: { $0.type == type })?.count ?? 0
    }
}
