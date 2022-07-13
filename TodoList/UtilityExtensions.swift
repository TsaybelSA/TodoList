//
//  UtilityExtensions.swift
//  TodoList
//
//  Created by Сергей Цайбель on 13.07.2022.
//

import RealmSwift

protocol IndexableObject: AnyObject {
	var index: Int { get set }
}

extension Results where Element: IndexableObject {

	func moveObject(from fromIndex: Int, to toIndex: Int) {

		let min = Swift.min(fromIndex, toIndex)
		let max = Swift.max(fromIndex, toIndex)

		let baseIndex = min

		var elementsInRange: [Element] = filter("index >= %@ AND index <= %@", min, max)
			.map { $0 }

		let source = elementsInRange.remove(at: fromIndex - baseIndex)
		elementsInRange.insert(source, at: toIndex - baseIndex)

		elementsInRange
			.enumerated()
			.forEach { (index, element) in
				element.index = index + baseIndex
			}
	}
}