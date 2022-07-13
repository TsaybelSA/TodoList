//
//  TodoItem.swift
//  TodoList
//
//  Created by Сергей Цайбель on 11.07.2022.
//

import Foundation
import RealmSwift

class TodoItem: Object {
	@Persisted var name: String = ""
	@Persisted var isDone: Bool = false
	@Persisted var id: Int = 0
	@Persisted var parentCategory = LinkingObjects(fromType: Category.self, property: "items")
}
