//
//  ViewController.swift
//  SimpleTimer
//
//  Created by Григорий Бойко on 11.09.2021.
//

import UIKit

class TimersViewController: UIViewController {
    
    //MARK: UI properties
    private let addLabel: UILabel = {
        let label = UILabel()
        label.text = "Добавление таймеров"
    
        return label
    }()
    private lazy var titleTimerTF: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Название таймера"
        tf.borderStyle = .roundedRect
        tf.addTarget(self, action: #selector(textFieldChanged), for: .editingChanged)
        tf.delegate = self
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    private lazy var timeTimerTF: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Время в секундах"
        tf.borderStyle = .roundedRect
        tf.keyboardType = .numberPad
        tf.addTarget(self, action: #selector(textFieldChanged), for: .editingChanged)
        tf.delegate = self
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    private lazy var addTimerButton: UIButton = {
        let button = UIButton()
        button.setTitle("Добавить", for: .normal)
        button.setTitleColor(.label, for: .normal)
        button.setTitleColor(.systemGray, for: .disabled)
        button.layer.cornerRadius = 5
        button.backgroundColor = .secondarySystemBackground
        button.addTarget(self, action: #selector(addButtonTapped), for: .touchUpInside)
        button.isEnabled = false
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var stackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.alignment = .fill
        sv.distribution = .fill
        sv.spacing = 10
        let views = [addLabel, titleTimerTF, timeTimerTF, addTimerButton]
        views.forEach { sv.addArrangedSubview($0) }
        
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()
    
    private lazy var tableView: UITableView = {
        let tv = UITableView()
        tv.dataSource = self
        tv.delegate = self
        tv.register(TimerCell.self, forCellReuseIdentifier: cellId)
        tv.rowHeight = 40
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()
    
    //MARK: Properties
    private let cellId = "cell"
    private let viewModel = TimersViewModel()
    
    private var timerName: String? {
        guard let title = titleTimerTF.text?.trimmingCharacters(in: .whitespaces), title != "" else {return nil}
        return title
    }
    private var timerSeconds: Int? {
        guard let text = timeTimerTF.text else {return nil}
        return Int(text)
    }
    

    
    //MARK: Life cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .systemBackground
        DispatchQueue.main.async {
            self.makeConstraints()
        }
        title = "Мульти таймер"
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(viewTapped))
        self.view.addGestureRecognizer(tap)
        
        viewModel.delegate = self
    }
    
    //MARK: Setup
    private func makeConstraints(){
        view.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 10),
            stackView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -10),
            stackView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 10),
            addLabel.heightAnchor.constraint(equalToConstant: 30),
            addTimerButton.heightAnchor.constraint(equalToConstant: 40),
            timeTimerTF.heightAnchor.constraint(equalToConstant: 30),
            titleTimerTF.heightAnchor.constraint(equalTo: timeTimerTF.heightAnchor),
            
            
        ])

        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: stackView.bottomAnchor, constant: 10),
            tableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            tableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            tableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            
        ])
    }
    //MARK: Handlers
    @objc func addButtonTapped(){
        guard let name = timerName,
              let seconds = timerSeconds,
              seconds > 0 else { return }
        viewModel.addTimerTask(name: name, seconds: seconds)
        self.view.endEditing(true)
    }
    @objc func viewTapped(_ recognizer: UITapGestureRecognizer){
        self.view.endEditing(true)
    }
}
//MARK: DataSource
extension TimersViewController: UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        "Таймеры"
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.timersCount
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! TimerCell

        cell.timerTask = viewModel.getTimerTask(for: indexPath)
        cell.delegate = self

        return cell
    }
    
}
//MARK: - TableViewDelegate
extension TimersViewController: UITableViewDelegate{
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == .delete) {
            viewModel.deleteTimerTask(indexPath: indexPath)
        }
    }

}
//MARK: - TimerTaskDelegate
extension TimersViewController: TimerTaskDelegate{
    func timerFired(for cell: TimerCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        viewModel.deleteTimerTask(indexPath: indexPath)
    }
    
}

// MARK: - TimersViewModelDelegate
extension TimersViewController: TimersViewModelDelegate {
    func updateUI() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    func removeCell(for indexPath: IndexPath) {
        tableView.deleteRows(at: [indexPath], with: .fade)
    }
    
    func updateTimerTasks() {
        guard let visibleRowsIndexPaths = tableView.indexPathsForVisibleRows else {
          return
        }
        
        for indexPath in visibleRowsIndexPaths {
          if let cell = tableView.cellForRow(at: indexPath) as? TimerDelegate {
            cell.updateTime()
          }
        }
    }
    

}

//MARK: TextFieldDelegate
extension TimersViewController: UITextFieldDelegate{

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField === titleTimerTF {
            timeTimerTF.becomeFirstResponder()
        }else {
            textField.resignFirstResponder()
        }
        return true
    }
    
    @objc func textFieldChanged(_ textField: UITextField){
        let result = timerName != nil && timerSeconds != nil
        DispatchQueue.main.async {
            self.addTimerButton.isEnabled = result
        }
    }
    
}

