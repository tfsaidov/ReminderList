//
//  ReminderListViewController.swift
//  ReminderList
//
//  Created by Саидов Тимур on 10.01.2023.
//

import UIKit

final class ReminderListViewController: UIViewController {
    
    typealias DataSource = UICollectionViewDiffableDataSource<Int, String> // DataSource property that implicitly unwraps a DataSource.
    typealias Snapshot = NSDiffableDataSourceSnapshot<Int, String> // Type alias for a diffable data source snapshot.

    
    // MARK: Public Properties
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    
    // MARK: Private Properties
    
    private var dataSource: DataSource!
    private var reminders = Reminder.sampleData
    
    private var reminderCompletedValue: String {
        NSLocalizedString("Completed", comment: "Reminder completed value")
    }
    
    private var reminderNotCompletedValue: String {
        NSLocalizedString("Not completed", comment: "Reminder not completed value")
    }
    
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupCollectionView()
    }
    
    
    // MARK: Private
    
    /// UICollectionView configuration.
    private func setupCollectionView() {
        self.collectionView.collectionViewLayout = self.listLayout() // Assign the list layout to the collection view layout.
        self.cellRegistration()
        self.updateSnapshot()
        self.collectionView.dataSource = self.dataSource // Assign the data source to the collection view.
    }
    
    /// Configuring the collection view appearance using compositional layout. Compositional layout lets you construct views by combining different components: sections, groups, and items. A section represents the outer container view that surrounds a group of items.
    private func listLayout() -> UICollectionViewCompositionalLayout {
        var listConfiguration = UICollectionLayoutListConfiguration(appearance: .grouped) // Creates a section in a list layout.
        listConfiguration.showsSeparators = false // Disable separators.
        listConfiguration.backgroundColor = .clear // Change the background color to clear.
        return UICollectionViewCompositionalLayout.list(using: listConfiguration)
    }
    
    /// Cells registration in the collection view, using a content configuration to define the appearance of the cells.
    /// Connection the cells to a data source.
    /// It will be a diffable data source, which updates and animates the user interface when the data changes.
    private func cellRegistration() {
        let cellRegistration = UICollectionView.CellRegistration(handler: cellRegistrationHandler)
        
        // Create a new data source. In the initializer, you pass a closure that configures and returns a cell for a collection view. The closure accepts two inputs: an index path to the location of the cell in the collection view and an item identifier.
        self.dataSource = DataSource(collectionView: self.collectionView) { (collectionView: UICollectionView, indexPath: IndexPath, itemIdentifier: Reminder.ID) in
            return collectionView.dequeueConfiguredReusableCell(using: cellRegistration,
                                                                for: indexPath,
                                                                item: itemIdentifier)
        }
    }
    
    /// Registering the cell to the list, configuring the displayed information and formatting the cell by using the cell registration method.
    /// - Parameters:
    ///
    private func cellRegistrationHandler(cell: UICollectionViewListCell, indexPath: IndexPath, id: Reminder.ID) {
        let reminder = self.reminder(for: id)
        
        var contentConfiguration = cell.defaultContentConfiguration()
        contentConfiguration.text = reminder.title
        contentConfiguration.secondaryText = reminder.dueDate.dayAndTimeText
        cell.contentConfiguration = contentConfiguration
        
        var doneButtonConfiguration = self.doneButtonConfiguration(for: reminder)
        doneButtonConfiguration.tintColor = .todayListCellDoneButtonTint
        // Adding a custom action to make the button accessible to VoiceOver.
        cell.accessibilityCustomActions = [
            self.doneButtonAccessibilityAction(for: reminder)
        ]
        cell.accessibilityValue = reminder.isComplete
        ? self.reminderCompletedValue
        : self.reminderNotCompletedValue
        cell.accessories = [
            .customView(configuration: doneButtonConfiguration),
            .disclosureIndicator(displayed: .always)
        ]
        
        var backgroundConfiguration = UIBackgroundConfiguration.listGroupedCell()
        backgroundConfiguration.backgroundColor = .todayListCellBackground
        cell.backgroundConfiguration = backgroundConfiguration // Using the provided background color asset doesn’t change the appearance from the default background color. It will fix this behavior in an upcoming section.
    }
    
    /// Returns the corresponding reminder from the reminders array.
    /// - Parameters:
    ///   - id: Reminder identifier.
    private func reminder(for id: Reminder.ID) -> Reminder {
        let index = self.reminders.indexOfReminder(with: id)
        return self.reminders[index]
    }
    
    /// Updating the corresponding reminder in the reminders array.
    /// - Parameters:
    ///   - reminder: Modified reminder.
    ///   - id: Reminder identifier.
    private func update(_ reminder: Reminder, with id: Reminder.ID) {
        let index = self.reminders.indexOfReminder(with: id)
        self.reminders[index] = reminder
    }
    
    /// Adding a circle-shaped button. The button serves both as an interface and as an indicator of the complete or incomplete status for each reminder.
    private func doneButtonConfiguration(for reminder: Reminder) -> UICellAccessory.CustomViewConfiguration {
        let symbolName = reminder.isComplete ? "circle.fill" : "circle"
        let symbolConfiguration = UIImage.SymbolConfiguration(textStyle: .title1)
        let image = UIImage(systemName: symbolName, withConfiguration: symbolConfiguration)
        let button = ReminderDoneButton()
        button.id = reminder.id
        button.addTarget(self, action: #selector(self.didPressDoneButton(_:)), for: .touchUpInside) // Target-action is a design pattern in which an object holds the information necessary to send a message to another object when an event occurs. Here the touchUpInside event occurs when a user taps the done button, which sends the didPressDoneButton:sender message to the view controller.
        button.setImage(image, for: .normal)
        return UICellAccessory.CustomViewConfiguration(customView: button, placement: .leading(displayed: .always))
    }
    
    /// Diffable data sources manage the state of data with snapshots. A snapshot represents the state of data at a specific point in time. To display data using a snapshot, snapshot should create, populate it with the state of data to display, and then apply the snapshot in the user interface.
    /// Thus when working with different data sources, a snapshot is applied to update the user interface when data changes.
    /// Creating and appling a new snapshot when the user clicks done.
    /// - Parameters:
    ///   - ids:Reminder’s identifiers when updating the snapshot.
    private func updateSnapshot(reloading ids: [Reminder.ID] = []) {
        var snapshot = Snapshot()
        snapshot.appendSections([0]) // Append sections to the snapshot. Adding a single section.
        snapshot.appendItems(self.reminders.map { $0.id }) // Append items to the snapshot.
        if !ids.isEmpty {
            snapshot.reloadItems(ids)
        }
        self.dataSource.apply(snapshot) // Apply the snapshot to the data source.
    }
    
    /// Reminder execution method.
    /// - Parameters:
    ///   - id: Reminder identifier.
    private func completeReminder(with id: Reminder.ID) {
        var reminder = self.reminder(for: id)
        reminder.isComplete.toggle()
        self.update(reminder, with: id)
        self.updateSnapshot(reloading: [id]) // Passing the reminder’s identifier when updating the snapshot.
    }
    
    /// Call this method in the cell registration handler to create a custom action for each cell.
    private func doneButtonAccessibilityAction(for reminder: Reminder) -> UIAccessibilityCustomAction {
        let name = NSLocalizedString("Toggle completion", comment: "Reminder done button accessibility label") // VoiceOver alerts users when actions are available for an object. If a user decides to hear the options, VoiceOver reads the name of each action.
        // Creating a UIAccessibilityCustomAction using the name that you defined in the previous step.
        return UIAccessibilityCustomAction(name: name) { [weak self] action in
            self?.completeReminder(with: reminder.id)
            return true
        }
    }
    
    @objc private func didPressDoneButton(_ sender: ReminderDoneButton) { // The @object attribute makes this method available to Objective-C code.
        guard let id = sender.id else { return }
        
        self.completeReminder(with: id)
    }
}
