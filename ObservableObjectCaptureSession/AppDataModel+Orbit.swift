extension AppDataModel {
    // Device orbit component of a data model that maintains the state of the app.
    enum Orbit: String, CaseIterable, Identifiable, Comparable {
        case orbit1 = "orbit1"
        case orbit2 = "orbit2"
        case orbit3 = "orbit3"
        
        var id: String {
            rawValue
        }
        
        var image: String {
            switch self {
            case .orbit1:
                "1.circle"
            case .orbit2:
                "2.circle"
            case .orbit3:
                "3.cirle"
            }
        }
        
        var imageSelected: String {
            switch self {
            case .orbit1:
                "1.circle.fill"
            case .orbit2:
                "2.circle.fill"
            case .orbit3:
                "3.circle.fill"
            }
        }
        
        func next() -> Self {
            let currentIndex = Self.allCases.firstIndex(of: self)!
            let nextIndex = Self.allCases.index(after: currentIndex)
            
            return Self.allCases[nextIndex == Self.allCases.endIndex ? Self.allCases.endIndex - 1 : nextIndex]
        }
        
        static func < (lhs: AppDataModel.Orbit, rhs: AppDataModel.Orbit) -> Bool {
            guard let lhsIndex = Self.allCases.firstIndex(of: lhs),
                  let rhsIndex = Self.allCases.firstIndex(of: rhs) else {
                return false
            }
            
            return lhsIndex < rhsIndex
        }
    }
}

extension AppDataModel {
    // A segment can have n orbits. An orbit can reset to go from the capturing state back to it's initial state
    enum OrbitState {
        case initial, capturing
    }
}
