import Foundation
import UIKit
import CoreData

//MARK: - CRUD

public final class CoreDataManager: NSObject {
    
    public static let shared = CoreDataManager()
    
    private override init() {
        super.init()
    }
    
    private var appDelegate: AppDelegate {
        UIApplication.shared.delegate as! AppDelegate
    }
    
    private var context: NSManagedObjectContext {
        appDelegate.persistentContainer.viewContext
    }
    
    //MARK: - Folder data manager
    
    func createFolder(_ title: String) -> Folder {
        guard let folderEntityDescription = NSEntityDescription.entity(forEntityName: "Folder", in: context) else {
            fatalError("Could not find entity description for Folder")
        }
        
        let folder = Folder(entity: folderEntityDescription, insertInto: context)
        folder.title = title
        appDelegate.saveContext()
        
        return folder
    }
    
    func fetchFolders() -> [Folder] {
        let fr = NSFetchRequest<NSFetchRequestResult>(entityName: "Folder")
        
        do {
            return try context.fetch(fr) as! [Folder]
        } catch {
            print(error.localizedDescription)
        }
        
        return []
    }
    
    func fetchFolder(_ title: String) -> Folder? {
        let fr = NSFetchRequest<NSFetchRequestResult>(entityName: "Folder")
        do {
            guard let folders = try? context.fetch(fr) as? [Folder] else { return nil }
            return folders.first(where: {$0.title == title})
        }
    }
    
    func updateFolder(_ title: String, folder: Folder) {
        folder.title = title
        appDelegate.saveContext()
    }
    
    func deleteFolder(_ folder: Folder) {
        context.delete(folder)
        appDelegate.saveContext()
    }
    
    //MARK: - Note data manager
    
    func createNote(to folder: Folder,
                    content: String,
                    isCompleted: Bool,
                    dueDate: Date,
                    timeOfDay: Int16,
                    priority: Int16) -> Note {
        
        // Проверка на наличие сущности в CoreData
        guard let noteEntityDescription = NSEntityDescription.entity(forEntityName: "Note", in: context) else {
            fatalError("Could not find entity description for Note")
        }
        
        // Создание новой заметки
        let newNote = Note(entity: noteEntityDescription, insertInto: context)
        
        // Настройка атрибутов заметки
        newNote.title = folder.title
        newNote.content = content
        newNote.dueDate = dueDate
        newNote.isComplete = isCompleted
        newNote.priority = priority
        
        // Добавление заметки в папку
        folder.addToNotes(newNote)
        
        // Сохранение контекста, если необходимо
        do {
            try context.save()
        } catch {
            // Обработка ошибки сохранения контекста
            print("Failed to save context: \(error)")
        }
        
        return newNote
    }
    
    func updateNote(_ oldNote: Note,
                    content: String,
                    isCompleted: Bool,
                    dueDate: Date,
                    timeOfDay: Int16,
                    priority: Int16) {
        // Обновление свойств заметки
        oldNote.content = content
        oldNote.isComplete = isCompleted
        oldNote.dueDate = dueDate
        oldNote.priority = priority
        
        // Сохранение контекста CoreData
        do {
            try oldNote.managedObjectContext?.save()
        } catch {
            // Обработка ошибки, если сохранение не удалось
            print("Не удалось сохранить обновленную заметку: \(error)")
        }
    }
    
    func fetchNotes(for folder: Folder) -> [Note] {
        let fetchRequest: NSFetchRequest<Note> = Note.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "folder == %@", folder)
        
        do {
            return try context.fetch(fetchRequest)
        } catch {
            print("Error fetching notes for folder \(folder.title ?? ""): \(error)")
            return []
        }
    }
    
    func deleteNote(_ note: Note) {
        context.delete(note)
        appDelegate.saveContext()
    }
}
