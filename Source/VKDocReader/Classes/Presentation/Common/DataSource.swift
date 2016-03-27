//
//  DataSource.swift
//  VKDocReader
//
//  Created by Yaroslav Ryabukha on 18/03/16.
//  Copyright © 2016 Yaroslav Ryabukha. All rights reserved.
//

import UIKit

/**
 Протокол для DataSource'ов, которому подчинаются все DataSource'ы приложения
 */
protocol DataSource: UITableViewDataSource {
    /**
    Обновить информацию из ВК (если есть взаимодествие с ВК)
    */
    func refresh(refreshEnded: () -> Void, refreshFailed: (error: Error) -> Void)
    func document(indexPath: NSIndexPath) -> Document
    func updateCache()
    func deleteElements(indexPaths: [NSIndexPath], completion: () -> Void, failure: (error: Error) -> Void)
}
