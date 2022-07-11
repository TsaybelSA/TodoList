//
//  ViewController.swift
//  TodoList
//
//  Created by Сергей Цайбель on 04.07.2022.
//

import SwiftUI
import CoreData

class TodoItemsViewController: UIViewController {
	
	var selectedCategory = Category()
	
	let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
	
	var items = [Item]()
	
	convenience init(_ category: Category) {
		self.init()
		self.selectedCategory = category
	}
	override func viewDidLoad() {
		super.viewDidLoad()
		view.backgroundColor = .white
		title = "\(selectedCategory.name!)"
		
		//Long Press gesture to edit
		let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
		longPressGesture.minimumPressDuration = 1
		self.tableView.addGestureRecognizer(longPressGesture)
		
		setupView()
		loadItems()
	}
	
	private let tableView: UITableView = {
		let tableView = UITableView()
		tableView.translatesAutoresizingMaskIntoConstraints = false
		return tableView
	}()
	
	private let searchBar: UISearchBar = {
		let searchBar = UISearchBar()
		searchBar.translatesAutoresizingMaskIntoConstraints = false
		return searchBar
	}()
	
	@objc func handleLongPress(longPressGesture: UILongPressGestureRecognizer) {
		isEditing = true
	}
	
	//MARK: - Setup view appearance
	
	private func setupView() {
		navigationController?.navigationBar.barTintColor = K.Colors.lightBlue
		navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonPressed))
		
		searchBar.delegate = self
		tableView.delegate = self
		tableView.dataSource = self
		tableView.register(TodoTableViewCell.self, forCellReuseIdentifier: "todoItemCell")
		tableView.rowHeight = 60
		tableView.allowsSelectionDuringEditing = true
		
		setupToHideKeyboardOnTapOnView()
		view.addSubview(searchBar)
		view.addSubview(tableView)
		NSLayoutConstraint.activate([
			searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
			searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
			searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
			tableView.topAnchor.constraint(equalTo: searchBar.bottomAnchor),
			tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
			tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
			tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
		])
	}
	
	//MARK: - Creating New Todo Item
	
	@objc private func addButtonPressed() {
		let ac = UIAlertController(title: "Add New Task", message: "", preferredStyle: .alert)
		ac.addTextField { textField in
			textField.placeholder = "Write task"
		}
		let confirmAction = UIAlertAction(title: "Add Item", style: .default) { _ in
			guard let text = ac.textFields!.first?.text else { return }
			guard text != " " && text != "" else { return }
			let newItem = Item(context: self.context)
			newItem.title = text
			newItem.isDone = false
			let safeIndex = NSNumber(integerLiteral: min(0, self.items.count))
			newItem.id = safeIndex
			newItem.parentCategory = self.selectedCategory
			self.items.append(newItem)
			self.saveItems()
		}
		let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
		ac.addAction(confirmAction)
		ac.addAction(cancelAction)
		present(ac, animated: true)
	}
	
	//MARK: - Model Manipulation Methods
	
	private func saveItems() {
		do {
			try context.save()
			print("Saved")
		} catch {
			print("Failed to save context: \(error)")
		}
		tableView.reloadData()
	}
	
	private func loadItems(with searchPredicate: NSPredicate? = nil) {
		do {
			guard let name = selectedCategory.name else { return }
			
			let request: NSFetchRequest<Item> = Item.fetchRequest()
			let categoryPredicate = NSPredicate(format: "parentCategory.name == %@", name)
			if let searchPredicate = searchPredicate {
				request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicate, searchPredicate])
			} else {
				request.predicate = categoryPredicate
			}
			request.sortDescriptors = [NSSortDescriptor(key: "id", ascending: true)]
			
			items = try context.fetch(request)
		} catch {
			print("Failed to fetch data from context! \(error)")
		}
		tableView.reloadData()
	}
}

//MARK: - Table View Methods

extension TodoItemsViewController: UITableViewDelegate {
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		items[indexPath.row].isDone.toggle()
		saveItems()
	}

	override func setEditing(_ editing: Bool, animated: Bool) {
		super.setEditing(editing, animated: animated)
		tableView.setEditing(editing, animated: animated)
		let addItemButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonPressed))
		navigationItem.rightBarButtonItem = isEditing == true ? editButtonItem : addItemButton
	}
	
	func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
		return true
	}
	//Moving rows
	func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
		let item = items[sourceIndexPath.row]
		items.remove(at: sourceIndexPath.row)
		items.insert(item, at: destinationIndexPath.row)
		for (index, item) in items.enumerated() {
			item.id = NSNumber(integerLiteral: index)
		}
		saveItems()
	}
	
	//edit todo item
	private func editCell(_ cell: TodoTableViewCell) -> Void {
		let vc = EditCellViewController()
		vc.item = cell.item
		vc.complition = { [weak self] todoItem in
			if let itemIndex = self?.items.firstIndex(where: { $0.id == todoItem.id }) {
				self?.items[itemIndex].title = todoItem.title
				self?.saveItems()
			}

		}
		present(vc, animated: true)
	}
	
	func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
		let deleteAction = UIContextualAction(style: .destructive, title: "Delete") {_,_,_ in
			self.context.delete(self.items[indexPath.row])
			self.items.remove(at: indexPath.row)
			self.saveItems()
		}
		return UISwipeActionsConfiguration(actions: [deleteAction])
	}
}

//MARK: - UITableViewDataSource

extension TodoItemsViewController: UITableViewDataSource {
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return items.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "todoItemCell", for: indexPath) as! TodoTableViewCell
		let item = items[indexPath.row]
		cell.setupCell(with: item, editHandler: editCell)
		return cell
	}
}

//MARK: - Search Bar Methods

extension TodoItemsViewController: UISearchBarDelegate {
	func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
		guard searchBar.text != "" else { loadItems(); return }
		let predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
		loadItems(with: predicate)
	}
	
	func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
		loadItems()
	}
	
	func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
		dismissKeyboard()
	}
}

