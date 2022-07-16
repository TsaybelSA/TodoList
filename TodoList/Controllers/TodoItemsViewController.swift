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
	//if need this realm configuration, need to add it to appDelegate
	let realmConfiguration: Realm.Configuration
	var notificationToken: NotificationToken?
	
	var items: Results<TodoItem>
	
	required init(realmConfiguration: Realm.Configuration, selectedCategory: Category) {
		self.realm = try! Realm(configuration: realmConfiguration)
		self.realmConfiguration = realmConfiguration
		
		self.selectedCategory = selectedCategory
		
		items = selectedCategory.items.sorted(byKeyPath: "index")

		super.init(nibName: nil, bundle: nil)
		
		createNotificationToken(for: items)
	}
	
	func createNotificationToken(for object: Results<TodoItem>) {
		notificationToken = items.observe { [weak self] (changes) in
			guard let tableView = self?.tableView else { return }
			switch changes {
			case .initial:
				tableView.reloadData()
			case .update(_, let deletions, let insertions, let modifications):
				tableView.performBatchUpdates({
					tableView.deleteRows(at: deletions.map({ IndexPath(row: $0, section: 0) }),
						with: .automatic)
					tableView.insertRows(at: insertions.map({ IndexPath(row: $0, section: 0) }),
						with: .automatic)
					tableView.reloadRows(at: modifications.map({ IndexPath(row: $0, section: 0) }),
						with: .automatic)
				})
				if let lastInsertedRow = insertions.last {
					tableView.scrollToRow(at: IndexPath(item: lastInsertedRow, section: 0),
										  at: .middle, animated: true)
					print("last row: \(lastInsertedRow)")
				}
			case .error(let error):
				fatalError("\(error)")
			}
		}
	}
	
	deinit {
		notificationToken?.invalidate()
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
		$0.register(TodoTableViewCell.self, forCellReuseIdentifier: "todoItemCell")
		$0.rowHeight = 60
		$0.allowsSelectionDuringEditing = true
		$0.translatesAutoresizingMaskIntoConstraints = false
		return $0 }(UITableView())
	
	private let searchBar: UISearchBar = {
		$0.translatesAutoresizingMaskIntoConstraints = false
	return $0 }(UISearchBar())
	
	@objc func handleLongPress(longPressGesture: UILongPressGestureRecognizer) {
		isEditing = true
//		self.searchBarCancelButtonClicked(searchBar)
	}
	
	//MARK: - Setup view appearance
	
	private func setupView() {
		navigationController?.navigationBar.barTintColor = K.CustomColors.iconColor
		navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonPressed))
		
		searchBar.delegate = self
		tableView.delegate = self
		tableView.dataSource = self
		
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
			newItem.index = max(0, self.items.count)
			self.saveItem(newItem)
		}
		print(items)
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
		items = selectedCategory.items.sorted(byKeyPath: "index")
		createNotificationToken(for: items)
	}
}

//MARK: - Table View Methods

extension TodoItemsViewController: UITableViewDelegate {
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		do {
			let item = items[indexPath.row]
			try realm.write {
				item.isDone.toggle()
			}
			guard item.isDone else { return }
			DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
				guard let self = self else { return }
				try! self.realm.write {
					item.index = self.items.last!.index + 1
				}
			}
		} catch {
			print("Error writing data to Realm database \(error)")
		}
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
		do {
			try self.realm.write {
				items.moveObject(from: sourceIndexPath.row, to: destinationIndexPath.row)
			}
		} catch {
			print("Failed to update data: \(error)")
		}
	}
	
	//edit todo item
	private func editCell(_ cell: TodoTableViewCell) -> Void {
		let vc = EditTodoCellViewController(cellItem: cell.item, realmConfiguration: realmConfiguration)
		present(vc, animated: true)
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
		cell.setupCell(with: items[indexPath.row], editHandler: editCell)
		return cell
	}
}

//MARK: - Search Bar Methods

extension TodoItemsViewController: UISearchBarDelegate {
	func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
		guard searchBar.text != "" else { loadItems(); return }
		
		items = selectedCategory.items.filter("name CONTAINS[cd] %@", searchText).sorted(byKeyPath: "index")
		createNotificationToken(for: items)
	}
	
	func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
		loadItems()
	}
	
	func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
		dismissKeyboard()
	}
}

