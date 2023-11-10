import Foundation
import UIKit
import CoreData

final class NoteDetailInfoVC: UIViewController {
    
    var note: Note?
    var context: NSManagedObjectContext?
    var onSave: (() -> Void)?
    var folder: Folder?
    
    // Создаем UI элементы
    let dueDatePicker = UIDatePicker()
    let prioritySegmentedControl = UISegmentedControl(items: ["ОБычная", "Важная", "Долгосрочная"])
    let timeOfdaySegmentControl = UISegmentedControl(items: ["Утро", "День", "Вечер"])
    let contentTextView = UITextView()
    let isCompletedSwitch = UISwitch()
   
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "Редактирование"

        // Настройка UI элементов и добавление их в view
        setupContentTextView()
        setupPrioritySegmentedControl()
        setupTimeOfDaySegmentControl()
        setupDueDatePicker()
        setupIsCompletedSwitch()

        // Установка значений по умолчанию из note
        if let note = note {
            contentTextView.text = note.content
            isCompletedSwitch.isOn = note.isComplete
            if let dueDate = note.dueDate {
                dueDatePicker.date = dueDate
            }
            let priorityIndex = Int(note.priority)
            let timeOfDayIndex = Int(note.timeOfDay)
            timeOfdaySegmentControl.selectedSegmentIndex = timeOfDayIndex
            prioritySegmentedControl.selectedSegmentIndex = priorityIndex
        }

        // Настройка навигационной кнопки
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Закрыть", style: .done, target: self, action: #selector(closeButtonTapped))

        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Сохранить", style: .done, target: self, action: #selector(saveNote))

        print("redact note: ", note)
    }
    
    // Функция настройки DatePicker
    func setupDueDatePicker() {
        dueDatePicker.datePickerMode = .date
        dueDatePicker.timeZone = TimeZone(identifier: "Europe/Moscow")
        view.addSubview(dueDatePicker)
        dueDatePicker.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            dueDatePicker.topAnchor.constraint(equalTo: timeOfdaySegmentControl.bottomAnchor, constant: 20),
            dueDatePicker.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            dueDatePicker.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }
    
    // Функция настройки SegmentedControl для приоритета
    func setupPrioritySegmentedControl() {
        view.addSubview(prioritySegmentedControl)
        prioritySegmentedControl.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            prioritySegmentedControl.topAnchor.constraint(equalTo: contentTextView.bottomAnchor, constant: 20),
            prioritySegmentedControl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            prioritySegmentedControl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }
    
    func setupTimeOfDaySegmentControl() {
        view.addSubview(timeOfdaySegmentControl)
        timeOfdaySegmentControl.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            timeOfdaySegmentControl.topAnchor.constraint(equalTo: prioritySegmentedControl.bottomAnchor, constant: 20),
            timeOfdaySegmentControl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            timeOfdaySegmentControl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
            ])
    }
    
    // Функция настройки Switch для статуса выполнения
    func setupIsCompletedSwitch() {
        view.addSubview(isCompletedSwitch)
        isCompletedSwitch.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            isCompletedSwitch.topAnchor.constraint(equalTo: timeOfdaySegmentControl.bottomAnchor, constant: 20),
            isCompletedSwitch.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20)
            // Switch обычно имеет стандартный размер, так что ограничения для правой стороны и низа не обязательны
        ])
    }
    
    func setupContentTextView() {
        contentTextView.layer.borderColor = UIColor.gray.cgColor
        contentTextView.layer.borderWidth = 1.0
        contentTextView.layer.cornerRadius = 8.0
        
        view.addSubview(contentTextView)
        contentTextView.translatesAutoresizingMaskIntoConstraints = false // Важно для активации Auto Layout
        
        NSLayoutConstraint.activate([
            contentTextView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            contentTextView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            contentTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            contentTextView.heightAnchor.constraint(equalToConstant: 400)
        ])
    }
    
    @objc func closeButtonTapped() {
        self.dismiss(animated: true, completion: nil)
    }
    
    // Функция для сохранения новой заметки
    @objc func saveNote() {
        // Получение значений из UI элементов
        let content = contentTextView.text ?? "" // используйте nil-coalescing, чтобы предотвратить nil значение
        let isCompleted = isCompletedSwitch.isOn
        let dueDate = dueDatePicker.date
        let priority = Int16(prioritySegmentedControl.selectedSegmentIndex) // Преобразование в Int16 для совместимости с моделью данных
        let timeOfDay = Int16(timeOfdaySegmentControl.selectedSegmentIndex)

        
        if let context = self.context, let folder = self.folder {
            // Создание новой заметки
            _ = CoreDataManager.shared.updateNote(note!, content: content, isCompleted: isCompleted, dueDate: dueDate, timeOfDay: timeOfDay, priority: priority)
            
            // Закрыть редактор заметок, если сохранение прошло успешно
            dismiss(animated: true) {
                // Вызов замыкания после закрытия
                self.onSave?()
            }
        } else {
            // Если контекст или папка не доступны, показать ошибку
            print("Ошибка: не удалось получить контекст или папку для сохранения заметки.")
        }
    }
}
