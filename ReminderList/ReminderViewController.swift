//
//  ReminderViewController.swift
//  ReminderList
//
//  Created by Саидов Тимур on 11.01.2023.
//

import UIKit

final class ReminderViewController: UICollectionViewController {
    
    private typealias DataSource = UICollectionViewDiffableDataSource<Int, Row>
    private typealias Snapshot = NSDiffableDataSourceSnapshot<Int, Row>
    
    // Instances of Row need to represent items in the detail list.
    private enum Row: Hashable {
        case viewDate
        case viewNotes
        case viewTime
        case viewTitle
        
        var imageName: String? {
            switch self {
            case .viewDate: return "calendar.circle"
            case .viewNotes: return "square.and.pencil"
            case .viewTime: return "clock"
            default: return nil
            }
        }

        var image: UIImage? {
            guard let imageName = imageName else { return nil }
            
            let configuration = UIImage.SymbolConfiguration(textStyle: .headline)
            return UIImage(systemName: imageName, withConfiguration: configuration)
        }
        
        var textStyle: UIFont.TextStyle {
            switch self {
            case .viewTitle: return .headline
            default: return .subheadline
            }
        }
    }
    
    var reminder: Reminder // The reminder view controller displays the details of this reminder. It's a variable to add the capability to edit the reminder in a future.
    
    private var dataSource: DataSource!
    
    init(reminder: Reminder) {
        self.reminder = reminder
        var listConfiguration = UICollectionLayoutListConfiguration(appearance: .insetGrouped) // Default configuration for most of the appearance and styling, with a few custom exceptions.
        listConfiguration.showsSeparators = false // Disable separators in the list configuration to remove the lines between the list cells.
        let listLayout = UICollectionViewCompositionalLayout.list(using: listConfiguration) // A list compositional layout contains only the layout information needed for a list.
        super.init(collectionViewLayout: listLayout)
    }
    
    required init?(coder: NSCoder) {
        fatalError("Always initialize ReminderViewController using init(reminder:)")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = NSLocalizedString("Reminder", comment: "Reminder view controller title")
        
        let cellRegistration = UICollectionView.CellRegistration(handler: self.cellRegistrationHandler)
        self.dataSource = DataSource(collectionView: self.collectionView) { (collectionView: UICollectionView, indexPath: IndexPath, itemIdentifier: Row) in
            return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: itemIdentifier)
        }
        
        self.updateSnapshot()
    }
    
    private func cellRegistrationHandler(cell: UICollectionViewListCell, indexPath: IndexPath, row: Row) {
        var contentConfiguration = cell.defaultContentConfiguration() // This configuration assigns the default styling to the rows.
        contentConfiguration.text = self.text(for: row)
        contentConfiguration.textProperties.font = UIFont.preferredFont(forTextStyle: row.textStyle)
        contentConfiguration.image = row.image
        cell.contentConfiguration = contentConfiguration
        cell.tintColor = .todayPrimaryTint
    }
    
    private func updateSnapshot() {
        var snapshot = Snapshot()
        snapshot.appendSections([0])
        snapshot.appendItems([.viewTitle, .viewDate, .viewTime, .viewNotes], toSection: 0)
        self.dataSource.apply(snapshot)
    }
    
    private func text(for row: Row) -> String? {
        switch row {
        case .viewDate: return reminder.dueDate.dayText
        case .viewNotes: return reminder.notes
        case .viewTime: return reminder.dueDate.formatted(date: .omitted, time: .shortened)
        case .viewTitle: return reminder.title
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 0
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return 0
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "", for: indexPath)
    
        // Configure the cell
    
        return cell
    }

    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */

}
