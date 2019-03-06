//
//  ViewController.swift
//  kindOfNotesApp
//
//  Created by Jakub Slawecki on 22/02/2019.
//  Copyright © 2019 Jakub Slawecki. All rights reserved.
//

import UIKit

class NotesViewController: UITableViewController, AddNoteViewControllerDelegate {
    @IBOutlet var emptyView: UIView!
    @IBOutlet weak var createNoteButton: UIButton!
    
    
    var notes = [NoteItem]() {
        didSet {
            if notes.count == 0 {
                tableView.backgroundView?.isHidden = false
            } else {
                tableView.backgroundView?.isHidden = true
            }
        }
    }
    
    
    override func viewDidLoad() {
        tableView.backgroundView = emptyView
        super.viewDidLoad()
        createNoteButton.layer.cornerRadius = 10.0
        loadNotes()
    }
    
    
    // MARK:- TableView DataSource
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notes.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "NoteItem", for: indexPath)
            let note = notes[indexPath.row]
            configureTitleAndText(for: cell, with: note)
            return cell
    }
    
    
    // MARK:- TableView Delegate
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            showDeleteNoteAlert(indexPath: indexPath)
            notes.remove(at: indexPath.row)
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
  
    
    // MARK:- Actions
    func dissmisVC() {
        navigationController?.popViewController(animated: true)
    }
    
    func deleteCell(indexPath: IndexPath) {
        tableView.beginUpdates()
        tableView.deleteRows(at: [indexPath], with: .automatic)
        tableView.endUpdates()
    }
    
    func configureTitleAndText(for cell: UITableViewCell, with note: NoteItem) {
        let titleLabel = cell.viewWithTag(1000) as! UILabel
        titleLabel.text = note.noteTitle
        
        let someTextOfTheNote = cell.viewWithTag(1001) as! UILabel
        someTextOfTheNote.text = note.noteText
    }
    
    func showSavedAlert() {
        let alert = UIAlertController(title: "Saved!", message: "Your Note has been saved.", preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: { _ in self.dissmisVC(); self.saveNoteItems()})
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    func showNotSavedAlert() {
        let alert = UIAlertController(title: "Changes are not saved.", message: "If you continue, you will lose unsaved changes.", preferredStyle: .alert)
        let action = UIAlertAction(title: "Continue", style: .default, handler: { _ in self.dissmisVC()})
        let action2 = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(action)
        alert.addAction(action2)
        present(alert, animated: true, completion: nil)
    }
    
    func showDeleteNoteAlert(indexPath: IndexPath) {
        let alert = UIAlertController(title: "Delete Note", message: "Are you sure you want to delete this note", preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: { _ in  self.deleteCell(indexPath: indexPath); self.saveNoteItems()})
        let action2 = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(action)
        alert.addAction(action2)
        present(alert, animated: true, completion: nil)
    }
    
    @discardableResult func showValidatePasswordAlert(note: NoteItem, sender: Any) -> Bool {
        let validatePasswordAlert = UIAlertController(title: "Note is locked.", message: "Please enter password for this note:", preferredStyle: .alert)
        
        let enable = UIAlertAction(title: "Continue", style: .default) {  (_) in
            let field = validatePasswordAlert.textFields?[0].text
            if field == note.password {
                self.performSegue(withIdentifier: "EditNote", sender: sender)
            } else {
                let wrongPassword = UIAlertController(title: "Wrong password", message: nil, preferredStyle: .alert)
                let okSadFaceAction = UIAlertAction(title: "Ok :(", style: .default, handler: nil)
                wrongPassword.addAction(okSadFaceAction)
                self.present(wrongPassword, animated: true, completion: nil)
            }
        }
        
        let action2 = UIAlertAction(title: "Cancel", style: .cancel) { (_) in }
        
        validatePasswordAlert.addTextField { (textField) in
            textField.placeholder = "Password"
            textField.isSecureTextEntry = true
        }
        
        validatePasswordAlert.addAction(enable)
        validatePasswordAlert.addAction(action2)
        present(validatePasswordAlert, animated: true, completion: nil)
        return false
    }
    
    
    // MARK:- AddNoteViewController Delegates
    func noteDetailViewControllerDidCancel(_ controller: NoteDetailViewController) {
        showNotSavedAlert()
    }
    
    
    func noteDetailViewController(_ controller: NoteDetailViewController, didFinishAdding note: NoteItem) {
        notes.append(note)
        
        let indexPath = IndexPath(row: notes.count - 1, section: 0)
        let indexPaths = [indexPath]
        
        tableView.beginUpdates()
        tableView.insertRows(at: indexPaths, with: .automatic)
        tableView.endUpdates()
        
        showSavedAlert()
    }
    
    
    func noteDetailViewController(_ controller: NoteDetailViewController, didFinishEditind note: NoteItem) {
        if let index = notes.index(of: note) {
            let indexPath = IndexPath(row: index, section: 0)
            if let cell = tableView.cellForRow(at: indexPath) {
                configureTitleAndText(for: cell, with: note)
            }
        }
        showSavedAlert()
    }
    
    
    // MARK:- Navigation
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == "EditNote" {
            if let indexPath = tableView.indexPath(for: sender as! UITableViewCell) {
                let note = notes[indexPath.row]
                if note.isLoced == true {
                    showValidatePasswordAlert(note: note, sender: sender!)
                }
            }
        }
        return true
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "AddNote" {
            let controller = segue.destination as! NoteDetailViewController
            controller.delegate = self
        } else if segue.identifier == "EditNote" {
            let controller = segue.destination as! NoteDetailViewController
            controller.delegate = self
            if let indexPath = tableView.indexPath(for: sender as! UITableViewCell) {
                controller.noteToEdit = notes[indexPath.row]
            }
        }
    }

    
    // MARK:- Data saving
    func saveNoteItems() {
        let encoder = PropertyListEncoder()
        do {
             let data = try encoder.encode(notes)
             try data.write(to: dataFilePath(), options: Data.WritingOptions.atomic)
        } catch {
            print("Error encoding item array: \(error.localizedDescription)")
        }
    }
    
    
    func loadNotes() {
        let path = dataFilePath()
        if let data = try? Data(contentsOf: path) {
            let decoder = PropertyListDecoder()
            do {
                notes = try decoder.decode([NoteItem].self, from: data)
            } catch {
                print("Error decoding item array: \(error.localizedDescription)")
            }
        }
    }
    
    
    func documentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    
    func dataFilePath() -> URL {
        return documentsDirectory().appendingPathComponent("kindOfNotesApp")
    }
    
}
