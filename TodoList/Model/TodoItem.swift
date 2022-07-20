//
//  TodoItem.swift
//  TodoList
//
//  Created by Сергей Цайбель on 11.07.2022.
//

import Foundation
import RealmSwift

class TodoItem: Object, IndexableObject {
	@Persisted var name: String = ""
	@Persisted var isDone: Bool = false
	@Persisted var index: Int = 0
	@Persisted var indexBeforeCompleted: Int?
	@Persisted var dateToRemind: Date?
	@Persisted var notificationIdentifier: String?
	@Persisted var parentCategory = LinkingObjects(fromType: Category.self, property: "items")
}
