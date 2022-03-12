//
// Copyright (c) Vatsal Manot
//

import Foundation
import SwiftUI

/// A utility class encapsulating the capabilities of the device's Taptic Engine (if available).
public final class FeedbackGenerator {
	public static let shared = FeedbackGenerator()
	
	public enum ImpactFeedbackStyle: Hashable {
		case light
		case medium
		case heavy
		case soft
		case rigid
	}
	
	public enum NotificationFeedbackStyle: Hashable {
		case success
		case warning
		case error
	}
	
	public enum FeedbackStyle: Hashable {
		case impact(ImpactFeedbackStyle)
		case notification(NotificationFeedbackStyle)
		case selection
		
		public static let light = Self.impact(.light)
		public static let medium = Self.impact(.medium)
		public static let heavy = Self.impact(.heavy)
		public static let soft = Self.impact(.soft)
		public static let rigid = Self.impact(.rigid)
		public static let success = Self.notification(.success)
		public static let warning = Self.notification(.warning)
		public static let error = Self.notification(.error)
	}
	
	private init() {
		
	}
	
	#if os(iOS) || targetEnvironment(macCatalyst)
	
	private var impactFeedbackGenerators: [UIImpactFeedbackGenerator.FeedbackStyle: UIImpactFeedbackGenerator] = [:]
	private var selectionFeedbackGenerator = UISelectionFeedbackGenerator()
	private var notificationFeedbackGenerator = UINotificationFeedbackGenerator()
	
	private func impactFeedbackGenerator(for style: UIImpactFeedbackGenerator.FeedbackStyle) -> UIImpactFeedbackGenerator {
		if let generator = impactFeedbackGenerators[style] {
			return generator
		} else {
			let generator = UIImpactFeedbackGenerator(style: style)
			impactFeedbackGenerators[style] = generator
			return generator
		}
	}
	
	#endif
	
	/// Prepare device for haptic feedback of a certain type.
	public func prepare(_ feedback: FeedbackStyle) {
		#if os(iOS) || targetEnvironment(macCatalyst)
		switch feedback  {
			case .impact(let style):
				impactFeedbackGenerator(for: .init(style)).prepare()
			case .selection:
				selectionFeedbackGenerator.prepare()
			case .notification:
				notificationFeedbackGenerator.prepare()
		}
		#endif
	}
	
	/// Generate a certain type of haptic feedback.
	public func generate(_ feedback: FeedbackStyle) {
		#if os(iOS) || targetEnvironment(macCatalyst)
		switch feedback  {
			case .impact(let style):
				impactFeedbackGenerator(for: .init(style)).impactOccurred()
			case .selection:
				selectionFeedbackGenerator.selectionChanged()
			case .notification(let type):
				notificationFeedbackGenerator.notificationOccurred(.init(type))
		}
		#endif
	}
}

// MARK: - Helpers -

#if os(iOS) || targetEnvironment(macCatalyst)
extension UIImpactFeedbackGenerator.FeedbackStyle {
	public init(_ style: FeedbackGenerator.ImpactFeedbackStyle) {
		switch style {
			case .light:
				self = .light
			case .medium:
				self = .medium
			case .heavy:
				self = .heavy
			case .soft:
				self = .soft
			case .rigid:
				self = .rigid
		}
	}
}

extension UINotificationFeedbackGenerator.FeedbackType {
	public init(_ style: FeedbackGenerator.NotificationFeedbackStyle) {
		switch style {
			case .success:
				self = .success
			case .warning:
				self = .warning
			case .error:
				self = .error
		}
	}
}
#endif
