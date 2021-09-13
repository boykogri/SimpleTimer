//
//  TimerCell.swift
//  SimpleTimer
//
//  Created by Григорий Бойко on 11.09.2021.
//

import UIKit

protocol TimerTaskDelegate: AnyObject{
    func timerFired(for cell: TimerCell)
}
protocol TimerDelegate: AnyObject {
    func updateTime()
}

class TimerCell: UITableViewCell, TimerDelegate {
    
    //MARK: Properties
    var timerTask: TimerTask? {
        didSet {
            titileLabel.text = timerTask?.name
            setLastTime()
            setImageForButton()
        }
    }
    weak var delegate: TimerTaskDelegate?

    //MARK: UI properties
    private lazy var titileLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var lastTimeLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .right

        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var pausePlayButton: UIButton = {
        let b = UIButton()

        b.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        return b
    }()
    
    private lazy var leftStackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.alignment = .center
        sv.distribution = .equalSpacing

        let views = [titileLabel, pausePlayButton]
        views.forEach {sv.addArrangedSubview($0)}
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()
    
    private lazy var totalStackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.alignment = .fill
        sv.distribution = .fill
        sv.spacing = 0
        let views = [leftStackView, lastTimeLabel]
        views.forEach {sv.addArrangedSubview($0)}
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()
    
    private var buttonImage: UIImage{
        var image: UIImage!
        if timerTask?.isActive == false{
            image = UIImage(systemName: "play.fill")
        }else {
            image = UIImage(systemName: "pause.fill")
        }
        return image
    }

    //MARK: Init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        DispatchQueue.main.async {
            self.setupUI()
        }
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    //MARK: Setup
    private func setupUI(){

        self.contentView.addSubview(totalStackView)
        NSLayoutConstraint.activate([

            totalStackView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -10),
            totalStackView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 10),
            totalStackView.topAnchor.constraint(equalTo: self.contentView.topAnchor),
            totalStackView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor),
            pausePlayButton.leftAnchor.constraint(equalTo: titileLabel.rightAnchor, constant: 5),
            pausePlayButton.heightAnchor.constraint(equalToConstant: 20),
            pausePlayButton.centerYAnchor.constraint(equalTo: totalStackView.centerYAnchor),

        ])
        
    
    }
    private func setImageForButton(){
        self.pausePlayButton.setImage(self.buttonImage, for: .normal)
    }
    private func setLastTime(){
        guard let lastSeconds = self.timerTask?.lastSeconds, lastSeconds > 0 else {
            self.delegate?.timerFired(for: self)
            return
        }
        DispatchQueue.main.async {
            self.lastTimeLabel.text = self.getLastTime(lastSeconds)
        }
    }
    
    //MARK: - TimerlDelegate
    func updateTime(){
        if timerTask?.isActive == true {
            setLastTime()
        }
    }
    
    //MARK: - Handlers
    @objc func buttonTapped(){
        StorageManager.shared.changeObject { [weak self] in
            self?.timerTask?.isActive.toggle()
        }
        setImageForButton()
    }
    
    //MARK: Helper
    private func getLastTime(_ lastSeconds: TimeInterval) -> String{
        let hours = Int(lastSeconds) / 3600
        let minutes = Int(lastSeconds) / 60 % 60
        let seconds = Int(lastSeconds) % 60
        
        var times: [String] = []
        if hours > 0 {
          times.append("\(hours)h")
        }
        if minutes > 0 {
          times.append("\(minutes)m")
        }
        times.append("\(seconds)s")
        
        return times.joined(separator: " ")
    }
}


