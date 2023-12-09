
@available(iOS 13.0, macOS 11.0, tvOS 13.0, watchOS 6.0, *)
public protocol SymbolLocalization {
    init(source: SFSymbol)
}

// TODO: replace the following with Variadic Generics once available
// Since the code is currently only an interim solution, we don't auto-generate it.
// Beware: if more localizations are added to SFSymbols before variadic generics are introduced to Swift, you may have to create the missing specialized classes.

// MARK: Static Localization

@dynamicMemberLookup
@available(iOS 13.0, macOS 11.0, tvOS 13.0, watchOS 6.0, *)
public class SymbolWith1Localization<L1: SymbolLocalization>: SFSymbol {
    subscript(dynamicMember keyPath: KeyPath<L1, SFSymbol>) -> SFSymbol {
        L1(source: self)[keyPath: keyPath]
    }
}

@dynamicMemberLookup
@available(iOS 13.0, macOS 11.0, tvOS 13.0, watchOS 6.0, *)
public class SymbolWith2Localizations<L1: SymbolLocalization, L2: SymbolLocalization>: SFSymbol {
    subscript(dynamicMember keyPath: KeyPath<L1, SFSymbol>) -> SFSymbol {
        L1(source: self)[keyPath: keyPath]
    }
    subscript(dynamicMember keyPath: KeyPath<L2, SFSymbol>) -> SFSymbol {
        L2(source: self)[keyPath: keyPath]
    }
}

@dynamicMemberLookup
@available(iOS 13.0, macOS 11.0, tvOS 13.0, watchOS 6.0, *)
public class SymbolWith3Localizations<L1: SymbolLocalization, L2: SymbolLocalization, L3: SymbolLocalization>: SFSymbol {
    subscript(dynamicMember keyPath: KeyPath<L1, SFSymbol>) -> SFSymbol {
        L1(source: self)[keyPath: keyPath]
    }
    subscript(dynamicMember keyPath: KeyPath<L2, SFSymbol>) -> SFSymbol {
        L2(source: self)[keyPath: keyPath]
    }
    subscript(dynamicMember keyPath: KeyPath<L3, SFSymbol>) -> SFSymbol {
        L3(source: self)[keyPath: keyPath]
    }
}

@dynamicMemberLookup
@available(iOS 13.0, macOS 11.0, tvOS 13.0, watchOS 6.0, *)
public class SymbolWith4Localizations<L1: SymbolLocalization, L2: SymbolLocalization, L3: SymbolLocalization, L4: SymbolLocalization>: SFSymbol {
    subscript(dynamicMember keyPath: KeyPath<L1, SFSymbol>) -> SFSymbol {
        L1(source: self)[keyPath: keyPath]
    }
    subscript(dynamicMember keyPath: KeyPath<L2, SFSymbol>) -> SFSymbol {
        L2(source: self)[keyPath: keyPath]
    }
    subscript(dynamicMember keyPath: KeyPath<L3, SFSymbol>) -> SFSymbol {
        L3(source: self)[keyPath: keyPath]
    }
    subscript(dynamicMember keyPath: KeyPath<L4, SFSymbol>) -> SFSymbol {
        L4(source: self)[keyPath: keyPath]
    }
}

@dynamicMemberLookup
@available(iOS 13.0, macOS 11.0, tvOS 13.0, watchOS 6.0, *)
public class SymbolWith5Localizations<L1: SymbolLocalization, L2: SymbolLocalization, L3: SymbolLocalization, L4: SymbolLocalization, L5: SymbolLocalization>: SFSymbol {
    subscript(dynamicMember keyPath: KeyPath<L1, SFSymbol>) -> SFSymbol {
        L1(source: self)[keyPath: keyPath]
    }
    subscript(dynamicMember keyPath: KeyPath<L2, SFSymbol>) -> SFSymbol {
        L2(source: self)[keyPath: keyPath]
    }
    subscript(dynamicMember keyPath: KeyPath<L3, SFSymbol>) -> SFSymbol {
        L3(source: self)[keyPath: keyPath]
    }
    subscript(dynamicMember keyPath: KeyPath<L4, SFSymbol>) -> SFSymbol {
        L4(source: self)[keyPath: keyPath]
    }
    subscript(dynamicMember keyPath: KeyPath<L5, SFSymbol>) -> SFSymbol {
        L5(source: self)[keyPath: keyPath]
    }
}

@dynamicMemberLookup
@available(iOS 13.0, macOS 11.0, tvOS 13.0, watchOS 6.0, *)
public class SymbolWith6Localizations<L1: SymbolLocalization, L2: SymbolLocalization, L3: SymbolLocalization, L4: SymbolLocalization, L5: SymbolLocalization, L6: SymbolLocalization>: SFSymbol {
    subscript(dynamicMember keyPath: KeyPath<L1, SFSymbol>) -> SFSymbol {
        L1(source: self)[keyPath: keyPath]
    }
    subscript(dynamicMember keyPath: KeyPath<L2, SFSymbol>) -> SFSymbol {
        L2(source: self)[keyPath: keyPath]
    }
    subscript(dynamicMember keyPath: KeyPath<L3, SFSymbol>) -> SFSymbol {
        L3(source: self)[keyPath: keyPath]
    }
    subscript(dynamicMember keyPath: KeyPath<L4, SFSymbol>) -> SFSymbol {
        L4(source: self)[keyPath: keyPath]
    }
    subscript(dynamicMember keyPath: KeyPath<L5, SFSymbol>) -> SFSymbol {
        L5(source: self)[keyPath: keyPath]
    }
    subscript(dynamicMember keyPath: KeyPath<L6, SFSymbol>) -> SFSymbol {
        L6(source: self)[keyPath: keyPath]
    }
}

@dynamicMemberLookup
@available(iOS 13.0, macOS 11.0, tvOS 13.0, watchOS 6.0, *)
public class SymbolWith7Localizations<L1: SymbolLocalization, L2: SymbolLocalization, L3: SymbolLocalization, L4: SymbolLocalization, L5: SymbolLocalization, L6: SymbolLocalization, L7: SymbolLocalization>: SFSymbol {
    subscript(dynamicMember keyPath: KeyPath<L1, SFSymbol>) -> SFSymbol {
        L1(source: self)[keyPath: keyPath]
    }
    subscript(dynamicMember keyPath: KeyPath<L2, SFSymbol>) -> SFSymbol {
        L2(source: self)[keyPath: keyPath]
    }
    subscript(dynamicMember keyPath: KeyPath<L3, SFSymbol>) -> SFSymbol {
        L3(source: self)[keyPath: keyPath]
    }
    subscript(dynamicMember keyPath: KeyPath<L4, SFSymbol>) -> SFSymbol {
        L4(source: self)[keyPath: keyPath]
    }
    subscript(dynamicMember keyPath: KeyPath<L5, SFSymbol>) -> SFSymbol {
        L5(source: self)[keyPath: keyPath]
    }
    subscript(dynamicMember keyPath: KeyPath<L6, SFSymbol>) -> SFSymbol {
        L6(source: self)[keyPath: keyPath]
    }
    subscript(dynamicMember keyPath: KeyPath<L7, SFSymbol>) -> SFSymbol {
        L7(source: self)[keyPath: keyPath]
    }
}

@dynamicMemberLookup
@available(iOS 13.0, macOS 11.0, tvOS 13.0, watchOS 6.0, *)
public class SymbolWith8Localizations<L1: SymbolLocalization, L2: SymbolLocalization, L3: SymbolLocalization, L4: SymbolLocalization, L5: SymbolLocalization, L6: SymbolLocalization, L7: SymbolLocalization, L8: SymbolLocalization>: SFSymbol {
    subscript(dynamicMember keyPath: KeyPath<L1, SFSymbol>) -> SFSymbol {
        L1(source: self)[keyPath: keyPath]
    }
    subscript(dynamicMember keyPath: KeyPath<L2, SFSymbol>) -> SFSymbol {
        L2(source: self)[keyPath: keyPath]
    }
    subscript(dynamicMember keyPath: KeyPath<L3, SFSymbol>) -> SFSymbol {
        L3(source: self)[keyPath: keyPath]
    }
    subscript(dynamicMember keyPath: KeyPath<L4, SFSymbol>) -> SFSymbol {
        L4(source: self)[keyPath: keyPath]
    }
    subscript(dynamicMember keyPath: KeyPath<L5, SFSymbol>) -> SFSymbol {
        L5(source: self)[keyPath: keyPath]
    }
    subscript(dynamicMember keyPath: KeyPath<L6, SFSymbol>) -> SFSymbol {
        L6(source: self)[keyPath: keyPath]
    }
    subscript(dynamicMember keyPath: KeyPath<L7, SFSymbol>) -> SFSymbol {
        L7(source: self)[keyPath: keyPath]
    }
    subscript(dynamicMember keyPath: KeyPath<L8, SFSymbol>) -> SFSymbol {
        L8(source: self)[keyPath: keyPath]
    }
}
