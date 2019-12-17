//
//  RealmStore.swift
//  PriconneDB
//
//  Created by Kazutoshi Baba on 2019/05/01.
//  Copyright © 2019 Kazutoshi Baba. All rights reserved.
//

import Foundation
import RealmSwift
import Realm

public class RealmStore: NSObject {
    public static let shared = RealmStore()
    private var realm: Realm!
    
    public override init() {
        super.init()
        // In Memory
        let config = Realm.Configuration(inMemoryIdentifier: "inMemory")
        do {
            realm = try Realm(configuration: config)
        } catch let error as NSError {
            log.error(error.localizedDescription)
            fatalError()
        }
    }
    
    // MARK: Units
    func addOrUpdateOrDelete(units: [Unit]) {
        do {
            try realm.write {
                // add or update
                self.realm.add(units, update: .all)
                // query all objects where key in not included
                let keys = units.map { $0.key }
                let objectsToDelete = self.realm.objects(Unit.self).filter("NOT key IN %@", keys)
                self.realm.delete(objectsToDelete)
            }
        } catch let error as NSError {
            log.error(error.localizedDescription)
        }
    }
  
    func units() -> [Unit] {
        let results = realm.objects(Unit.self).sorted(byKeyPath: "position", ascending: true)
        return Array(results)
    }
    
    func findUnitsIn(names: [String]) -> [Unit] {
        let results = realm.objects(Unit.self).filter("name IN %@", names)
        return Array(results)
    }
    
    // MARK: Team
    func addOrUpdateOrDelete(defensedTeams: [DefenseTeam]) {
        do {
            try realm.write {
                // add or update
                self.realm.add(defensedTeams, update: .all)
                // query all objects where key in not included
                let keys = defensedTeams.map { $0.key }
                let objectsToDelete = self.realm.objects(DefenseTeam.self).filter("NOT key IN %@", keys)
                self.realm.delete(objectsToDelete)
            }
        } catch let error as NSError {
            log.error(error.localizedDescription)
        }
    }
    
    func defensedTeams() -> [DefenseTeam] {
        let results = realm.objects(DefenseTeam.self).sorted(byKeyPath: "lastUpdated", ascending: false)
        return Array(results)
    }
    
    func filterDefensedTeamsIn(names: [String], uid: String = "") -> [DefenseTeam] {
        var predicates: [NSPredicate] = names.map({ NSPredicate(format: "ANY members.name == %@", $0) })
        predicates += [NSPredicate(format: "uid == %@", uid)]
        let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        let results = realm.objects(DefenseTeam.self).filter(predicate).sorted(byKeyPath: "lastUpdated", ascending: false)
        return Array(results)
    }

    func addWinningTeamToDefensiveTeam(team: DefenseTeam, winTeam: AttackTeam) {
        do {
            try realm.write {
                team.wins.append(winTeam)
                team.lastUpdated = Date()
            }
        } catch let error as NSError {
            log.error(error.localizedDescription)
        }
    }
    
    func deleteWinningTeamFrom(team: DefenseTeam, at index: Int) {
        do {
            try realm.write {
                team.wins.remove(at: index)
                team.lastUpdated = Date()
            }
        } catch let error as NSError {
            log.error(error.localizedDescription)
        }
    }

    func update(_ block: () -> Void) {
        do {
            try realm.write {
                block()
            }
        } catch let error as NSError {
            log.error(error.localizedDescription)
        }
    }
}
