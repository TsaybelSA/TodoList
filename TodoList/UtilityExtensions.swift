//
//  UtilityExtensions.swift
//  TodoList
//
//  Created by Сергей Цайбель on 13.07.2022.
//
import UIKit
import RealmSwift

protocol IndexableObject: AnyObject {
	var index: Int { get set }
}

extension Results where Element: IndexableObject {

	func moveObject(from fromIndex: Int, to toIndex: Int) {

		let baseIndex = Swift.min(fromIndex, toIndex)

		var elementsInRange: [Element] = self.map { $0 }

		let source = elementsInRange.remove(at: fromIndex - baseIndex)
		elementsInRange.insert(source, at: toIndex - baseIndex)

		elementsInRange
			.enumerated()
			.forEach { (index, element) in
				element.index = index + baseIndex
			}
	}
}
extension Date {
	func getStringFromDate() -> NSAttributedString {
		let relativeDateFormatter = RelativeDateTimeFormatter()
		relativeDateFormatter.unitsStyle = .full
		
		let color = self < Date() ? UIColor.red : .secondaryLabel
		
		let attributes: [NSAttributedString.Key: Any] = [.foregroundColor: color]
		let attributedString = NSAttributedString(string: relativeDateFormatter.string(for: self)!, attributes: attributes)
		return attributedString
	}
}

