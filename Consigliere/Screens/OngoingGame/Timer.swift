import UIKit

final class TimerView: UIView {
    
    // MARK: - UI Components
    
    private let speechLabel: UILabel = {
        let label = UILabel()
        label.text = "Speech"
        label.font = .systemFont(ofSize: 24)
        label.textAlignment = .left
        return label
    }()
    
    private let timerLabel: UILabel = {
        let label = UILabel()
        label.text = "0:00.0"
        label.font = .systemFont(ofSize: 48, weight: .bold)
        label.textAlignment = .right
        return label
    }()
    
    private let progressView: UIProgressView = {
        let view = UIProgressView(progressViewStyle: .default)
        view.progressTintColor = .systemIndigo
        view.trackTintColor = .systemGray4
        view.setProgress(0, animated: false)
        return view
    }()
    
    private let button30: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("30s", for: .normal)
        button.setTitleColor(.systemIndigo, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16)
        button.backgroundColor = .systemGray4
        button.layer.cornerRadius = 8
        return button
    }()
    
    private let button60: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("60s", for: .normal)
        button.setTitleColor(.systemIndigo, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16)
        button.backgroundColor = .systemGray4
        button.layer.cornerRadius = 8
        return button
    }()
    
    private let pauseButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "pause.fill"), for: .normal)
        button.tintColor = .white
        button.backgroundColor = .systemGray
        button.layer.cornerRadius = 8
        return button
    }()
    
    private let endSpeechButton: UIButton = {
        let button = UIButton(type: .system)
        if #available(iOS 15.0, *) {
            var config = UIButton.Configuration.filled()
            config.title = "End speech"
            config.image = UIImage(systemName: "forward.fill")
            config.imagePadding = 6
            config.baseBackgroundColor = .systemIndigo
            config.baseForegroundColor = .white
            config.cornerStyle = .medium
            button.configuration = config
        } else {
            button.setTitle("End speech", for: .normal)
            button.setImage(UIImage(systemName: "forward.fill"), for: .normal)
            button.imageEdgeInsets = UIEdgeInsets(top: 0, left: -6, bottom: 0, right: 0)
        }
        return button
    }()
    
    // MARK: - Timer Logic
    
    private var timer: Timer?
    private var remainingTime: Double = 0
    private var totalTime: Double = 0
    private var isPaused: Bool = false
    
    private var timerEndDate: Date?
    
    // MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    // MARK: - Setup UI
    
    private func setupView() {
        backgroundColor = .clear
        
        backgroundColor = UIColor.systemGray5
        layer.cornerRadius = 20
        layer.masksToBounds = false
        
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.1
        layer.shadowOffset = CGSize(width: 0, height: 4)
        layer.shadowRadius = 10


        
        let topRowStack = UIStackView(arrangedSubviews: [speechLabel, timerLabel])
        topRowStack.axis = .horizontal
        topRowStack.distribution = .equalSpacing
        topRowStack.alignment = .lastBaseline
        topRowStack.translatesAutoresizingMaskIntoConstraints = false
        
        let smallButtonsStack = UIStackView(arrangedSubviews: [button30, button60, pauseButton])
        smallButtonsStack.axis = .horizontal
        smallButtonsStack.spacing = 8
        smallButtonsStack.distribution = .fillEqually
        smallButtonsStack.translatesAutoresizingMaskIntoConstraints = false
        
        let buttonsContainer = UIStackView(arrangedSubviews: [smallButtonsStack, endSpeechButton])
        buttonsContainer.axis = .vertical
        buttonsContainer.spacing = 12
        buttonsContainer.translatesAutoresizingMaskIntoConstraints = false
        
        progressView.translatesAutoresizingMaskIntoConstraints = false
        endSpeechButton.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(topRowStack)
        addSubview(progressView)
        addSubview(buttonsContainer)
        
        NSLayoutConstraint.activate([
            topRowStack.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            topRowStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            topRowStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            
            progressView.topAnchor.constraint(equalTo: topRowStack.bottomAnchor, constant: 8),
            progressView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            progressView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            progressView.heightAnchor.constraint(equalToConstant: 4),
            
            buttonsContainer.topAnchor.constraint(equalTo: progressView.bottomAnchor, constant: 16),
            buttonsContainer.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            buttonsContainer.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            
            endSpeechButton.heightAnchor.constraint(equalToConstant: 50),
        ])
        
        button30.addTarget(self, action: #selector(start30Seconds), for: .touchUpInside)
        button60.addTarget(self, action: #selector(start60Seconds), for: .touchUpInside)
        pauseButton.addTarget(self, action: #selector(pauseTapped), for: .touchUpInside)
        endSpeechButton.addTarget(self, action: #selector(endSpeechTapped), for: .touchUpInside)
        
        updateLabel()
    }
    
    // MARK: - Timer Actions
    
    @objc private func start30Seconds() {
        isPaused = false
        pauseButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
        startTimer(seconds: 30)
    }
    
    @objc private func start60Seconds() {
        isPaused = false
        pauseButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
        startTimer(seconds: 60)
    }
    
    private func startTimer(seconds: Double, isResuming: Bool = false) {
        timer?.invalidate()
        
        if !isResuming {
            totalTime = seconds
        }
        remainingTime = seconds
        updateLabel()
        
       
        timerEndDate = Date().addingTimeInterval(seconds)
        
        scheduleTimerFinishedNotification(at: timerEndDate!)
        
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] timer in
            guard let self = self else { return }
            self.remainingTime -= 0.1
            if self.remainingTime <= 0 {
                self.remainingTime = 0
                timer.invalidate()
                self.timer = nil
                self.updateLabel()
                return
            }
            self.updateLabel()
        }
        RunLoop.main.add(timer!, forMode: .common)
    }

    
    private func scheduleTimerFinishedNotification(at date: Date) {
        let content = UNMutableNotificationContent()
        content.title = "Speech timer finished"
        content.body = "The timer has ended."
        content.sound = .default

        let triggerDate = Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute, .second],
            from: date
        )
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
        
        let request = UNNotificationRequest(identifier: "speechEnded", content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Failed to schedule notification: \(error)")
            }
        }
    }



    
    @objc private func pauseTapped() {
        if timer != nil {
            timer?.invalidate()
            timer = nil
            isPaused = true
            pauseButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
        } else if remainingTime > 0 {
            startTimer(seconds: remainingTime, isResuming: true)
            isPaused = false
            pauseButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
        }
    }


    
    @objc private func endSpeechTapped() {
        timer?.invalidate()
        timer = nil
        remainingTime = 0
        totalTime = 0
        isPaused = false
        pauseButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
        updateLabel()
    }
    
    // MARK: - Update Display
    
    private func updateLabel() {
        let total = max(remainingTime, 0)
        let minutes = Int(total) / 60
        let seconds = Int(total) % 60
        let tenth = Int((total - floor(total)) * 10)
        let fullText = String(format: "%d:%02d.%d", minutes, seconds, tenth)
        
        let attr = NSMutableAttributedString(string: fullText)
        if let dotRange = fullText.range(of: ".") {
            let nsRange = NSRange(dotRange.lowerBound..., in: fullText)
            attr.addAttribute(.font, value: UIFont.systemFont(ofSize: 32, weight: .bold), range: nsRange)
        }
        timerLabel.attributedText = attr
        
        let progress = totalTime > 0 ? Float(total / totalTime) : 0
        progressView.setProgress(progress, animated: true)
    }
}
