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

    @IBOutlet weak var collectionView: UICollectionView!
    
    var dataSource: DataSource!
    
    
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
        self.createSnapshot()
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
        let cellRegistration = UICollectionView.CellRegistration { (cell: UICollectionViewListCell, indexPath: IndexPath, itemIdentifier: String) in
            let reminder = Reminder.sampleData[indexPath.item]
            var contentConfiguration = cell.defaultContentConfiguration()
            contentConfiguration.text = reminder.title
            cell.contentConfiguration = contentConfiguration
        }
        
        // Create a new data source. In the initializer, you pass a closure that configures and returns a cell for a collection view. The closure accepts two inputs: an index path to the location of the cell in the collection view and an item identifier.
        self.dataSource = DataSource(collectionView: self.collectionView) { (collectionView: UICollectionView, indexPath: IndexPath, itemIdentifier: String) in
            return collectionView.dequeueConfiguredReusableCell(using: cellRegistration,
                                                                for: indexPath,
                                                                item: itemIdentifier)
        }
    }
    
    /// Diffable data sources manage the state of data with snapshots. A snapshot represents the state of data at a specific point in time. To display data using a snapshot,  snapshot should create, populate it with the state of data to display, and then apply the snapshot in the user interface.
    private func createSnapshot() {
        var snapshot = Snapshot()
        snapshot.appendSections([0]) // Append sections to the snapshot. Adding a single section.
        snapshot.appendItems(Reminder.sampleData.map { $0.title }) // Append items to the snapshot.
        self.dataSource.apply(snapshot) // Apply the snapshot to the data source.
        
        self.collectionView.dataSource = self.dataSource // Assign the data source to the collection view.
    }
}
