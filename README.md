# CardDex - Pokémon Card Collection App

A modern iOS app for managing your Pokémon card collection, built with SwiftUI and SwiftData.

![iOS 17.0+](https://img.shields.io/badge/iOS-17.0%2B-blue)
![Swift 5.9+](https://img.shields.io/badge/Swift-5.9%2B-orange)
![SwiftUI](https://img.shields.io/badge/SwiftUI-Framework-green)

## Features

### Implemented
- **Card Collection Management**
  - Browse your collection in grid or list view
  - Search and filter by name, type, rarity, and set
  - Sort by name, set, rarity, or date added
  - View detailed card information
  - Track quantity owned
  - Automatic image caching

- **Smart Card Search**
  - Search by set name (e.g., "Journey Together", "Base Set")
  - Search by card name (e.g., "Charizard", "Pikachu")
  - Search by card number (e.g., "25/167")
  - Bulk card selection and addition
  - Visual feedback for cards already in collection

- **Card Details**
  - High-resolution card images
  - Complete Pokémon stats (HP, types, attacks, abilities)
  - Weakness and resistance information
  - Retreat cost and evolution info
  - Set information and rarity
  - Artist attribution

### Planned Features
- Deck builder with validation
- Price tracking integration
- Collection statistics and analytics
- Export/import collection data
- Share collection with friends

## Screenshots

[Add screenshots here]

## Tech Stack

- **UI Framework**: SwiftUI
- **Persistence**: SwiftData
- **Networking**: URLSession with async/await
- **Image Loading**: Custom CachedAsyncImage
- **API**: [TCGdex](https://api.tcgdex.net/) - Free Pokémon TCG database

## Architecture

```
CardDex/
├── App/
│   ├── CardDexApp.swift           # App entry point with SwiftData setup
│   └── ContentView.swift          # Main tab navigation
│
├── Models/
│   ├── Card.swift                 # Main card model
│   ├── CardSet.swift              # Set model
│   ├── Deck.swift                 # Deck model
│   ├── DeckCard.swift             # Card-Deck relationship
│   └── Supporting/
│       ├── Attack.swift           # Attack data structure
│       ├── Ability.swift          # Ability data structure
│       └── TypeEffect.swift       # Weakness/Resistance data
│
├── ViewModels/
│   ├── CardLibraryViewModel.swift # Collection management logic
│   └── SearchViewModel.swift      # Card search logic
│
├── Services/
│   ├── API/
│   │   ├── TCGdexService.swift    # TCGdex API client
│   │   ├── APIError.swift         # Error handling
│   │   └── Models/
│   │       ├── CardAPIResponse.swift # API response models
│   │       └── APIMapper.swift       # API to Model mapping
│   └── ImageCacheService.swift    # Image caching system
│
├── Views/
│   ├── CardLibrary/
│   │   ├── CardLibraryView.swift  # Main collection view
│   │   ├── CardGridView.swift     # Grid layout
│   │   ├── CardListView.swift     # List layout
│   │   ├── CardDetailView.swift   # Card details
│   │   └── FilterView.swift       # Filtering interface
│   ├── Search/
│   │   └── CardSearchView.swift   # Card search interface
│   └── Components/
│       ├── CachedAsyncImage.swift # Cached image loader
│       └── TypeBadgeView.swift    # Energy type badges
│
└── Utilities/
    └── Constants/
        ├── APIConstants.swift     # API configuration
        └── AppConstants.swift     # App-wide constants
```

## Getting Started

### Prerequisites
- Xcode 15.0 or later
- iOS 17.0+ deployment target
- Internet connection for API access

### Installation

1. **Clone or download the project**
   ```bash
   git clone https://github.com/ObviouslyMartin/CardDex
   cd CardDex
   ```

2. **Open in Xcode**
   ```bash
   open CardDex.xcodeproj
   ```

3. **Build and Run**
   - Select your target device/simulator
   - Press `Cmd + R` to build and run

### First Launch
On first launch, the app will:
- Initialize SwiftData storage
- Set up image caching
- Present an empty collection view

## Usage

### Adding Cards to Your Collection

1. **Navigate to Search Tab**
2. **Choose Search Mode**:
   - **Set Name**: Search for entire sets (e.g., "Base Set 2")
   - **Card Name**: Search by Pokémon name (e.g., "Charizard")
   - **Card Number**: Search by number on card (e.g., "25/167")
3. **Select Cards**: Tap cards to select, adjust quantity with stepper
4. **Add to Collection**: Tap "Add Selected Cards" button

### Viewing Your Collection

1. **Browse**: Scroll through grid or list view
2. **Search**: Use search bar to filter by name
3. **Filter**: Apply filters for type, rarity, or set
4. **Sort**: Change sort order in menu
5. **View Details**: Tap any card for full information

### Managing Cards

- **Adjust Quantity**: Use +/- buttons in card detail view
- **Delete Card**: Tap trash icon in card detail view
- **View in Context**: See which decks use the card

## Configuration

### API Configuration
The app uses TCGdex API. No API key required!

```swift
// APIConstants.swift
static let baseURL = "https://api.tcgdex.net/v2/en"
```

### Image Caching
Images are cached both in memory and on disk:
- Memory cache: 100 MB limit
- Disk cache: 500 MB limit
- Automatic cleanup of old images

## Data Models

### Card
The main model for Pokémon cards, supporting:
- All card types (Pokémon, Trainer, Energy)
- Complete card data (attacks, abilities, stats)
- Collection tracking (quantity owned, date added)
- Relationship to decks

### Storage
- **Format**: SwiftData (SQLite-backed)
- **Complex Types**: Encoded as JSON Data
- **Images**: Cached separately, referenced by URL
- **Relationships**: Automatic cascade deletion

## Known Issues

- Slow up / time-to-search

## Contributing

This is a personal project, but suggestions are welcome!

## License

MIT License

Copyright (c) 2025 Martin Plut

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.


## Acknowledgments

- **TCGdex API** - Free Pokémon TCG database
- **Anthropic Claude** - Development assistance
- **Pokémon Company** - Card images and data
---

**Current Version**: 1.0.0  
**Last Updated**: February 2026  
**Status**: Active Development  

## Roadmap

### Version 1.1
- [ ] Deck builder functionality
- [ ] Price tracking integration
- [ ] Advanced filtering options

### Version 1.2
- [ ] Collection statistics
- [ ] Export/Import collection
- [ ] Barcode scanning for quick add

### Version 2.0
- [ ] Social features
- [ ] Trade management
- [ ] Wishlist functionality
