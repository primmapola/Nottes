import UIKit

class NotesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var folder: Folder!
    var notes: [Note] = []
    let tableView = UITableView() // Добавляем UITableView
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let notesOrderedSet = folder.notes {
            notes = (notesOrderedSet.array as? [Note]) ?? []
        }
        
        tableView.reloadData() // Перезагрузить данные в таблице
        print(notes.count) // Проверить актуальное количество заметок
        print(notes)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        self.title = folder.title
        
        if let notesOrderedSet = folder.notes {
            _ = notesOrderedSet.array as? [Note] ?? []
        }
        
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonTapped))
        self.navigationItem.rightBarButtonItem = addButton
        
        setupTableView()
    }
    
    func setupTableView() {
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        // Регистрация UITableViewCell с идентификатором "noteCell" и стилем "subtitle"
        //        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "noteCell")
        tableView.delegate = self
        tableView.dataSource = self
        
        // Установка констрейнтов для tableView
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leftAnchor.constraint(equalTo: view.leftAnchor),
            tableView.rightAnchor.constraint(equalTo: view.rightAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    
    @objc func addButtonTapped() {
        let noteEditorVC = NoteEditorViewController()
        noteEditorVC.folder = self.folder
        
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            noteEditorVC.context = appDelegate.persistentContainer.viewContext
        }
        
        noteEditorVC.onSave = { [weak self] in
            // Перезагрузить данные, возможно, вам потребуется вызвать метод для загрузки данных заново из контекста CoreData
            self?.notes = CoreDataManager.shared.fetchNotes(for: self!.folder!)
            self?.tableView.reloadData()
        }
        
        let navigationController = UINavigationController(rootViewController: noteEditorVC)
        self.present(navigationController, animated: true, completion: nil)
    }
}

extension NotesViewController {
    
    // MARK: - TableView DataSource Methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "noteCell"
        var cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier)
        if cell == nil {
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: cellIdentifier)
            cell?.textLabel?.numberOfLines = 0 // Разрешить множество строк
            cell?.detailTextLabel?.numberOfLines = 0 // Разрешить множество строк
        }
        
        let note = notes[indexPath.row]
        cell?.textLabel?.text = note.title
        cell?.detailTextLabel?.text = note.content
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44.0
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        // Действие удаления
        let deleteAction = UIContextualAction(style: .destructive, title: "Удалить") { [weak self] (action, view, completionHandler) in
            guard let self = self else { return }
            
            // Получаем заметку для удаления
            let noteToDelete = self.notes[indexPath.row]
            
            // Удаляем заметку из контекста CoreData
            CoreDataManager.shared.deleteNote(noteToDelete)
            
            // Удаляем заметку из массива и обновляем таблицу
            self.notes.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            
            completionHandler(true)
        }
        
        // Действие "Выполнено"
        let completeAction = UIContextualAction(style: .normal, title: "Выполнено") { [weak self] (action, view, completionHandler) in
            guard let self = self else { return }
            
            // Получаем заметку для обновления
            let noteToComplete = self.notes[indexPath.row]
            
            // Обновляем статус заметки
            noteToComplete.isComplete = true
            CoreDataManager.shared.updateNote(noteToComplete,
                                              content: noteToComplete.content ?? "",
                                              isCompleted: true,
                                              dueDate: noteToComplete.dueDate ?? Date(), timeOfDay: noteToComplete.timeOfDay,
                                              priority: noteToComplete.priority)
            
            // Перезагружаем соответствующую ячейку
            tableView.reloadRows(at: [indexPath], with: .automatic)
            
            completionHandler(true)
        }
        
        completeAction.backgroundColor = .green // Вы можете выбрать любой цвет
        
        // Возвращаем оба действия в конфигурации
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction, completeAction])
        return configuration
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Снимаем выделение с ячейки
        tableView.deselectRow(at: indexPath, animated: true)
        
        // Получаем заметку, которая была выбрана
        let note = notes[indexPath.row]
        
        // Создаем экземпляр NoteDetailInfoViewController
        let noteDetailVC = NoteDetailInfoVC()
        // Здесь вы можете передать заметку в noteDetailVC
        noteDetailVC.note = note
        noteDetailVC.folder = self.folder
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            noteDetailVC.context = appDelegate.persistentContainer.viewContext
        }
        
        noteDetailVC.onSave = { [weak self] in
            // Перезагрузить данные, возможно, вам потребуется вызвать метод для загрузки данных заново из контекста CoreData
            self?.notes = CoreDataManager.shared.fetchNotes(for: self!.folder!)
            self?.tableView.reloadData()
        }
        
        let navigationController = UINavigationController(rootViewController: noteDetailVC)
        self.present(navigationController, animated: true, completion: nil)
    }
}
