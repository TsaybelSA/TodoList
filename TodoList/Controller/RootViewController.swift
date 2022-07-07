//
//  ViewController.swift
//  TodoList
//
//  Created by Сергей Цайбель on 04.07.2022.
//

import SwiftUI
import CoreData

class RootViewController: UIViewController {
	
	let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
	
	var items = [Item]()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		view.backgroundColor = .white
		title = "Todo List"
		navigationController?.navigationBar.prefersLargeTitles = true
				
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
	
	//MARK: - Setup view appearance
	
	private func setupView() {
		navigationController?.navigationBar.barTintColor = K.Colors.lightBlue
		navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonPressed))
		
		searchBar.delegate = self
		tableView.delegate = self
		tableView.dataSource = self
		tableView.register(TableViewCell.self, forCellReuseIdentifier: "reusableCell")
		tableView.rowHeight = 50
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
			newItem.id = UUID()
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
	
	private func loadItems(with request: NSFetchRequest<Item> = Item.fetchRequest()) {
		do {
			items = try context.fetch(request)
		} catch {
			print("Failed to fetch data from context! \(error)")
		}
		tableView.reloadData()
	}
}

//MARK: - Table View Methods

extension RootViewController: UITableViewDelegate {
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		items[indexPath.row].isDone.toggle()
		saveItems()
	}

	override func setEditing(_ editing: Bool, animated: Bool) {
		super.setEditing(editing, animated: animated)
		tableView.setEditing(editing, animated: true)
	}

	private func editCell(_ cell: TableViewCell) -> Void {
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

extension RootViewController: UITableViewDataSource {
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return items.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "reusableCell", for: indexPath) as! TableViewCell
		let item = items[indexPath.row]
		cell.setupCell(with: item, editHandler: editCell)
		return cell
	}
}

//MARK: - Search Bar Methods

extension RootViewController: UISearchBarDelegate {
	func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
		guard searchBar.text != "" else { loadItems(); return }
		let request: NSFetchRequest<Item> = Item.fetchRequest()
		request.predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
		request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
		loadItems(with: request)
	}
	
	func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
		loadItems()
	}
}



struct SwiftUIController: UIViewControllerRepresentable {
	typealias UIViewControllerType = RootViewController
	
	func makeUIViewController(context: Context) -> UIViewControllerType {
		let vc = UIViewControllerType()
		return vc
	}
	
	func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
	}
}

struct SwiftUIController_Previews: PreviewProvider {
	static var previews: some View {
		SwiftUIController().edgesIgnoringSafeArea(.all)
	}
}

