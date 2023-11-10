//
//  ViewController.swift
//  PokaNetFilms
//
//  Created by Grigory Don on 02.11.2023.
//

import UIKit

class FoldersViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let tableView = UITableView()
    var folders = CoreDataManager.shared.fetchFolders()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        self.title = "Папки"
        if navigationController == nil {
            print("NavigationController отсутствует")
        } else {
            print("NavigationController присутствует")
        }
        
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonTapped))
        self.navigationItem.rightBarButtonItem = addButton
        
        setupTableView()
    }
    
    func setupTableView() {
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        
        // Активация констрейнтов
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leftAnchor.constraint(equalTo: view.leftAnchor),
            tableView.rightAnchor.constraint(equalTo: view.rightAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    @objc func addButtonTapped() {
        let alertController = UIAlertController(title: "Новая папка", message: "Введите название для новой папки", preferredStyle: .alert)
        
        alertController.addTextField { textField in
            textField.placeholder = "Название папки"
        }
        
        let addAction = UIAlertAction(title: "Добавить", style: .default) { [weak self] _ in
            guard let textField = alertController.textFields?.first, let name = textField.text, !name.isEmpty else {
                return
            }
            
            let newFolder = CoreDataManager.shared.createFolder(name)
            self?.addFolder(newFolder)
        }
        
        let cancelAction = UIAlertAction(title: "Отмена", style: .cancel)
        
        alertController.addAction(addAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true)
    }
    
    func addFolder(_ newfolder: Folder) {
        folders.append(newfolder)
        tableView.reloadData()
    }
    
}

extension FoldersViewController {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let folder = folders[indexPath.row]
        
        cell.textLabel?.text = folder.title
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        folders.count
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true // Возвращает true, чтобы разрешить редактирование строки
    }
    
    // Обработка удаления заметки
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            deleteFolder(at: indexPath)
        }
    }
    
    // Функция для удаления папки
    func deleteFolder(at indexPath: IndexPath) {
        // Получаем папку, которую хотим удалить
        let folderToDelete = folders[indexPath.row]
        
        // Удаление папки из контекста CoreData
        CoreDataManager.shared.deleteFolder(folderToDelete)
        
        // Удаление папки из массива
        folders.remove(at: indexPath.row)
        
        // Удаление строки из таблицы с анимацией
        tableView.deleteRows(at: [indexPath], with: .automatic)
    }
}

//MARK: - Navigation

extension FoldersViewController {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Создаем экземпляр NotesViewController
        let notesVC = NotesViewController()
        
        // Передаем выбранную папку в notesVC
        notesVC.folder = folders[indexPath.row]
        
        // Пушим notesVC на стек навигации
        navigationController?.pushViewController(notesVC, animated: true)
    }
}

