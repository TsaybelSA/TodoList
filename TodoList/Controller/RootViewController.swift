//
//  ViewController.swift
//  TodoList
//
//  Created by Сергей Цайбель on 04.07.2022.
//

import SwiftUI

class RootViewController: UIViewController {
	
	let filePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("todoItems")
	
	var items = [TodoItem(text: "First but not least"), TodoItem(text: "one more"), TodoItem(text: "just do it"), TodoItem(text: "good job!")]
	
	private let tableView: UITableView = {
		let tableView = UITableView()
		tableView.translatesAutoresizingMaskIntoConstraints = false
		return tableView
	}()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		view.backgroundColor = .white
		title = "Todo List"
		navigationController?.navigationBar.prefersLargeTitles = true
		
		setupView()
		loadItems()
	}
	
	//MARK: - Setup view appearance
	
	private func setupView() {
		navigationController?.navigationBar.barTintColor = K.Colors.lightBlue
		navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonPressed))
		
		tableView.delegate = self
		tableView.dataSource = self
		tableView.register(TableViewCell.self, forCellReuseIdentifier: "reusableCell")
		tableView.rowHeight = 50
		tableView.allowsSelectionDuringEditing = true
		
		
		view.addSubview(tableView)
		NSLayoutConstraint.activate([
			tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
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
			let newItem = TodoItem(text: text)
			guard newItem.text != "" else { return }
			self.items.append(newItem)
			self.tableView.reloadData()
			self.saveItems()
		}
		let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
		ac.addAction(confirmAction)
		ac.addAction(cancelAction)
		present(ac, animated: true)
	}
	
	private func saveItems() {
		do {
			let encoded = try JSONEncoder().encode(items)
			try encoded.write(to: filePath!)
			print("Saved")

		} catch {
			print(error)
		}
	}
	
	private func loadItems() {
		do {
			guard let data = try? Data(contentsOf: filePath!) else { return }
			let decodedData = try JSONDecoder().decode([TodoItem].self, from: data)
			DispatchQueue.main.async {
				self.items = decodedData
				self.tableView.reloadData()
				print("Loaded")
			}
		} catch {
			print(error)
		}
	}
}

//MARK: - UITableViewDelegate

extension RootViewController: UITableViewDelegate {
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

		if items[indexPath.row].isDone {
			items[indexPath.row].isDone = false
		} else {
			items[indexPath.row].isDone = true
		}
		saveItems()
		tableView.reloadData()
	}

	override func setEditing(_ editing: Bool, animated: Bool) {
		super.setEditing(editing, animated: animated)
		
		tableView.setEditing(editing, animated: true)
	}
	
	//MARK: - Edit Cell

	private func editCell(_ cell: TableViewCell) -> Void {
		let vc = EditCellViewController()
		vc.todoItem = cell.todoItem
		vc.complition = { [weak self] todoItem in
			if let itemIndex = self?.items.firstIndex(where: { $0.id == todoItem.id }) {
				self?.items[itemIndex].text = todoItem.text
				self?.tableView.reloadData()
				self?.saveItems()
			}

		}
		present(vc, animated: true)
	}
	
	func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
		let deleteAction = UIContextualAction(style: .destructive, title: "Delete") {_,_,_ in
			let cell = tableView.cellForRow(at: indexPath) as! TableViewCell
			guard let index = self.items.firstIndex(where: { $0.id == cell.todoItem.id }) else { return }
			self.items.remove(at: index)
			self.saveItems()
			tableView.reloadData()
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

