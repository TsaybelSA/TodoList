//
//  Category.swift
//  TodoList
//
//  Created by Сергей Цайбель on 11.07.2022.
//

import Foundation
import RealmSwift

class Category: Object {
	@Persisted var name: String = ""
	@Persisted var id: Int = 0
	@Persisted var items: List<TodoItem>
}
