//
//  TrackerStore.swift
//  TrackerYandexPracticum
//
//  Created by admin on 23.12.2023.
//

import UIKit
import CoreData

protocol TrackerStoreDelegate: AnyObject {
    func trackerStore(didUpdate update: TrackerStoreUpdate)
}


final class TrackerStore: NSObject {
    
    private let context: NSManagedObjectContext
    private var fetchedResultsController: NSFetchedResultsController<TrackerCD>
    
    private var insertedIndexes: [IndexPath]?
    private var deletedIndexes: [IndexPath]?
    private var updatedIndexes: [IndexPath]?
    
    weak var delegate: TrackerStoreDelegate?
    
    //MARK: - Init
    
    convenience override init() {
        guard let application = UIApplication.shared.delegate as? AppDelegate else {
            fatalError("не удалось получить application в TrackerStore")
        }
        let context = application.persistentContainer.viewContext
        self.init(context: context)
    }
    
    init(context: NSManagedObjectContext) {
        self.context = context
        
        let request = TrackerCD.fetchRequest()
        request.sortDescriptors = [
            NSSortDescriptor(keyPath: \TrackerCD.name, ascending: true)
        ]
        let controller = NSFetchedResultsController(fetchRequest: request,
                                                    managedObjectContext: context,
                                                    sectionNameKeyPath: nil,
                                                    cacheName: nil)
        self.fetchedResultsController = controller
        super.init()
        controller.delegate = self
        try? controller.performFetch()
    }
    
    func addNew(tracker: Tracker, to category: TrackerCategoryCD) throws {
        let trackerInCD = TrackerCD(context: context)
        trackerInCD.name = tracker.name
        trackerInCD.id = tracker.id
        trackerInCD.color = Int32(tracker.color)
        trackerInCD.emoji = Int32(tracker.emoji)
        trackerInCD.category = category
        trackerInCD.monday = tracker.schedule[0]
        trackerInCD.tuesday = tracker.schedule[1]
        trackerInCD.wednesday = tracker.schedule[2]
        trackerInCD.thursday = tracker.schedule[3]
        trackerInCD.friday = tracker.schedule[4]
        trackerInCD.satuday = tracker.schedule[5]
        trackerInCD.sunday = tracker.schedule[6]
        saveContext()
    }
    
    func fetchTrackers(byID id: UUID) -> TrackerCD? {
        let request = TrackerCD.fetchRequest()
        request.returnsObjectsAsFaults = false
        guard let trackers = try? context.fetch(request) else { return nil }
        return trackers.first { $0.id == id }
    }
    
    func deleteTrackersFromCD() {
        let request = TrackerCD.fetchRequest()
        let trackers = try? context.fetch(request)
        trackers?.forEach { context.delete($0) }
        saveContext()
    }
}

extension TrackerStore: NSFetchedResultsControllerDelegate {
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            if let newIndexPath {
                insertedIndexes?.append(newIndexPath)
            }
        case .delete:
            if let indexPath {
                deletedIndexes?.append(indexPath)
            }
        case .move:
            if let indexPath, let newIndexPath {
                insertedIndexes?.append(newIndexPath)
                deletedIndexes?.append(indexPath)
            }
        case .update:
            if let indexPath {
                updatedIndexes?.append(indexPath)
            }
        default:
            break
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        guard
            let insertedFinalIndexes = insertedIndexes,
            let deletedFinalIndexes = deletedIndexes,
            let updatedFinalIndexes = updatedIndexes
        else { return }
        delegate?.trackerStore(didUpdate: TrackerStoreUpdate(insertedIndexes: insertedFinalIndexes,
                                                             deletedIndexes: deletedFinalIndexes,
                                                             updatedIndexes: updatedFinalIndexes))
        
        insertedIndexes = nil
        deletedIndexes = nil
        updatedIndexes = nil
    }
}

extension TrackerStore {
    func saveContext() {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                assertionFailure("не удалось сохранить context в TrackerStore с ошибкой \(nserror), \(nserror.userInfo)")
            }
        }
    }
}
