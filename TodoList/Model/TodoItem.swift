//
//  TodoItem.swift
//  TodoList
//
//  Created by Сергей Цайбель on 05.07.2022.
//

import Foundation

struct TodoItem: Codable {
	var text: String
	var id = UUID()
}
