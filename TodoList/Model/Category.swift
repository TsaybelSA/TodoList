//
//  Category.swift
//  TodoList
//
//  Created by Сергей Цайбель on 11.07.2022.
//

import Foundation
import RealmSwift

class Category: Object, IndexableObject {
	@Persisted var name: String = ""
	@Persisted var index: Int = 0
	@Persisted var icon: String?
	@Persisted var items: List<TodoItem>
}
