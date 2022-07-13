//
//  CategoryViewController.swift
//  TodoList
//
//  Created by Сергей Цайбель on 07.07.2022.
//

import UIKit
import RealmSwift

class CategoryViewController: UIViewController {
	
	let realm: Realm
	let realmConfiguration: Realm.Configuration
	var notificationToken: NotificationToken?
	
	var categories: Results<Category>
		
	required init(realmConfiguration: Realm.Configuration, title: String) {
		self.realm = try! Realm(configuration: realmConfiguration)
		self.realmConfiguration = realmConfiguration
		   
	   // Access all tasks in the realm, sorted by _id so that the ordering is defined.
	   categories = realm.objects(Category.self).sorted(byKeyPath: "id")


		super.init(nibName: nil, bundle: nil)

		self.title = title

		// Observe the tasks for changes. Hang on to the returned notification token.
		notificationToken = categories.observe { [weak self] (changes) in
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
	
	deinit {
		// Always invalidate any notification tokens when you are done with them.
		notificationToken?.invalidate()
	}
	
    override func viewDidLoad() {
        super.viewDidLoad()

		view.backgroundColor = .white
		title = "What Todo"
		navigationController?.navigationBar.prefersLargeTitles = true
		
		print(Realm.Configuration.defaultConfiguration.fileURL)
		
		setupView()
    }
	
	private let tableView: UITableView = {
		let tableView = UITableView()
		tableView.translatesAutoresizingMaskIntoConstraints = false
		return tableView
	}()
	
	
	//MARK: - Setup view appearance
	
	private func setupView() {
		navigationController?.navigationBar.barTintColor = K.Colors.lightBlue
		navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonPressed))
		navigationItem.leftBarButtonItem = editButtonItem
		
//		private var barLabel = UIBarButtonItem()
//		toolbarItems = [barLabel]
//		navigationController?.setToolbarHidden(false, animated: false)
		
		tableView.delegate = self
		tableView.dataSource = self
		tableView.register(CategoryTableViewCell.self, forCellReuseIdentifier: "categoryCell")
		tableView.rowHeight = 50
		tableView.allowsSelectionDuringEditing = true
		
		setupToHideKeyboardOnTapOnView()
		view.addSubview(tableView)
		NSLayoutConstraint.activate([
			tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
			tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
			tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
			tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
		])
	}

	//MARK: - Creating New Category
	
	@objc private func addButtonPressed() {
		let ac = UIAlertController(title: "Add New Category", message: "", preferredStyle: .alert)
		ac.addTextField { textField in
			textField.placeholder = "Write title"
		}
		let confirmAction = UIAlertAction(title: "Add Category", style: .default) { _ in
			guard let text = ac.textFields!.first?.text else { return }
			guard text != " " && text != "" else { return }

			do {
				try self.realm.write {
					let newCategory = Category()
					newCategory.name = text
					newCategory.id = min(0, self.categories.count)
					self.realm.add(newCategory)
				}
			} catch {
				print("Failed to save data: \(error)")
			}
		}
		let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
		ac.addAction(confirmAction)
		ac.addAction(cancelAction)
		present(ac, animated: true)
	}
	
	//MARK: - Model Manipulation Methods
	
//	private func saveCategories() {
//		do {
//			try context.save()
//			print("Saved")
//		} catch {
//			print("Failed to save context: \(error)")
//		}
//		tableView.reloadData()
//	}
//
//	private func loadCategories(with request: NSFetchRequest<Category> = Category.fetchRequest()) {
//		do {
//			request.sortDescriptors = [NSSortDescriptor(key: "id", ascending: true)]
//			categories = try context.fetch(request)
//		} catch {
//			print("Failed to fetch data from context! \(error)")
//		}
//		tableView.reloadData()
//	}
	
	override func setEditing(_ editing: Bool, animated: Bool) {
		super.setEditing(editing, animated: animated)
		tableView.setEditing(editing, animated: animated)
	}
	
}

//MARK: - Table View Methods

extension CategoryViewController: UITableViewDelegate {
	
	// prepare and push todoItemsViewController
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let vc = TodoItemsViewController(realmConfiguration: realmConfiguration, selectedCategory: categories[indexPath.row])
		navigationController?.pushViewController(vc, animated: true)
	}
	
	//Moving rows
	func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
		let category = categories[sourceIndexPath.row]
		do {
			try self.realm.write {
				realm.delete(category)
				category.id = destinationIndexPath.row
				realm.add(category)
				for (index, item) in categories.enumerated() {
					item.id = index
				}
			}
		} catch {
			print("Error writing data to Realm database \(error)")
		}

	}
	
	func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
		let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { _,_,_ in
			do {
				try self.realm.write {
					self.realm.delete(self.categories[indexPath.row])
				}
			} catch {
				print("Error writing data to Realm database \(error)")
			}
		}
		return UISwipeActionsConfiguration(actions: [deleteAction])
	}
}

extension CategoryViewController: UITableViewDataSource {
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return categories.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "categoryCell", for: indexPath) as! CategoryTableViewCell
		cell.setupCell(with: categories[indexPath.row].name)
		return cell
	}
}
