//
//  ViewController.swift
//  TodoList
//
//  Created by Сергей Цайбель on 04.07.2022.
//

import SwiftUI
import RealmSwift

class TodoItemsViewController: UIViewController {
	
	var selectedCategory = Category()
	
	let realm: Realm
	var notificationToken: NotificationToken?
	
	var items: Results<TodoItem>
	
	required init(realmConfiguration: Realm.Configuration, selectedCategory: Category) {
		self.realm = try! Realm(configuration: realmConfiguration)
		
		self.selectedCategory = selectedCategory
		
		items = selectedCategory.items.sorted(byKeyPath: "id")

		super.init(nibName: nil, bundle: nil)

		// Observe the tasks for changes. Hang on to the returned notification token.
		notificationToken = items.observe { [weak self] (changes) in
			guard let tableView = self?.tableView else { return }
			switch changes {
			case .initial:
				// Results are now populated and can be accessed without blocking the UI
				tableView.reloadData()
			case .update(_, let deletions, let insertions, let modifications):
				// Query results have changed, so apply them to the UITableView.
				tableView.performBatchUpdates({
					// It's important to be sure to always update a table in this order:
					// deletions, insertions, then updates. Otherwise, you could be unintentionally
					// updating at the wrong index!
					tableView.deleteRows(at: deletions.map({ IndexPath(row: $0, section: 0) }),
						with: .automatic)
					tableView.insertRows(at: insertions.map({ IndexPath(row: $0, section: 0) }),
						with: .automatic)
					tableView.reloadRows(at: modifications.map({ IndexPath(row: $0, section: 0) }),
						with: .automatic)
				})
			case .error(let error):
				// An error occurred while opening the Realm file on the background worker thread
				fatalError("\(error)")
			}
		}
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		view.backgroundColor = .white
		title = "\(selectedCategory.name)"
		
		//Long Press gesture to edit
		let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
		longPressGesture.minimumPressDuration = 1
		self.tableView.addGestureRecognizer(longPressGesture)
		
		setupView()
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
			let newItem = TodoItem()
			newItem.name = text
			newItem.id = min(0, self.selectedCategory.items.count)
			self.saveItem(newItem)

		}
		let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
		ac.addAction(confirmAction)
		ac.addAction(cancelAction)
		present(ac, animated: true)
	}
	
	//MARK: - Model Manipulation Methods
	
	private func saveItem(_ newItem: TodoItem) {
		do {
			try self.realm.write {
				self.selectedCategory.items.append(newItem)
			}
		} catch {
			print("Error writing data to Realm database \(error)")
		}
	}
	
	private func loadItems() {
		items = selectedCategory.items.sorted(byKeyPath: "id")
	}
}

//MARK: - Table View Methods

extension TodoItemsViewController: UITableViewDelegate {
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		items[indexPath.row].isDone.toggle()
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
//	func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
//		let itemToMove = items[sourceIndexPath.row]
//		let newInstance = TodoItem()
//		newInstance.name = itemToMove.name
//		newInstance.id = destinationIndexPath.row
//
//		do {
//			try realm.write {
//				selectedCategory.items.append(newInstance)
//				realm.delete(itemToMove)
//
//
////				for (index, item) in items.enumerated() {
////					item.id = index
////					print("item name: \(item.name), id: \(item.id)")
////				}
//			}
//		} catch {
//			print("Error writing data to Realm database \(error)")
//		}
//	}
	
	
	//edit todo item
	private func editCell(_ cell: TodoTableViewCell) -> Void {
//		let vc = EditCellViewController()
//		vc.item = cell.item
//		vc.complition = { [weak self] todoItem in
//			if let itemIndex = self?.items.firstIndex(where: { $0.id == todoItem.id }) {
//				self?.items[itemIndex].title = todoItem.title
//				self?.saveItems()
//			}
//
//		}
//		present(vc, animated: true)
	}
	
	func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
		let deleteAction = UIContextualAction(style: .destructive, title: "Delete") {_,_,_ in
			do {
				try self.realm.write {
					self.realm.delete(self.items[indexPath.row])
				}
			} catch {
				print("Error deleting item from Realm database \(error)")
			}
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
		
		items = selectedCategory.items.filter("name CONTAINS[cd] %@", searchText).sorted(byKeyPath: "id")
	}
	
	func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
		loadItems()
	}
	
	func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
		dismissKeyboard()
	}
}

