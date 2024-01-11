//
//  CategoryViewController.swift
//  TrackerYandexPracticum
//
//  Created by admin on 11.01.2024.
//

import UIKit

protocol CategoryViewControllerDelegate: AnyObject {
    func categoryViewController(_ viewController: CategoryViewController, select category: TrackerCategory)
}

final class CategoryViewController: UIViewController {
    
    private lazy var titleLabel = {
        let label = UILabel()
        label.text = "Категория"
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var emptyView = {
        let view = EmptyView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.setEmptyView(title: "Привычки и события можно \nобъединить по смыслу",
                          image: UIImage(named: "tracker_placeholder"))
        return view
    }()
    
    private lazy var addButton = {
        let button = TypeButton()
        button.setTitle("Добавить категорию", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var tableView = {
        let tableView = UITableView()
        tableView.layer.cornerRadius = 16
        tableView.isScrollEnabled = true
        tableView.allowsSelection = true
        tableView.separatorColor = .ypGray
        return tableView
    }()
    
    private var selectedCategoryID: UUID?
    private var viewModel = CategoryViewModel()
    
    weak var delegate: CategoryViewControllerDelegate?
    
    //MARK: - init
    
    init(selectedCategoryID: UUID) {
        super.init(nibName: nil, bundle: nil)
        self.selectedCategoryID = selectedCategoryID
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - viewDidLoad
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        view.backgroundColor = .ypWhite
        
        setupUI()
        updateCategoryTableView()
        
        viewModel.onChange = updateCategoryTableView
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(CategoryCell.self, forCellReuseIdentifier: CategoryCell.Identifer)
        addButton.addTarget(self, action: #selector(addButtonPressed), for: .touchUpInside)
        
    }
}

private extension CategoryViewController {
    func updateCategoryTableView() {
        tableView.reloadData()
        tableView.isHidden = viewModel.categories.isEmpty
        emptyView.isHidden = !tableView.isHidden
    }
    
    @objc func addButtonPressed() {
        let nextController = AddCategoryViewController()
        nextController.delegate = self
        present(nextController, animated: true)
    }
}

//MARK: - AddCategoryViewControllerDelegate

extension CategoryViewController: AddCategoryViewControllerDelegate {
    func AddCategoryViewController(_ viewController: CategoryViewController, didAddCategory category: TrackerCategory) {
        dismiss(animated: true) { [weak self] in
            guard let self = self else { return }
            self.viewModel.addCategory(category)
        }
    }
}

extension CategoryViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        selectedCategoryID = viewModel.categories[indexPath.row].id
        delegate?.categoryViewController(self, select: viewModel.categories[indexPath.row])
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return viewModel.categories.isEmpty ? .zero : Constants.CategoryViewControllerConstants.categoryFieldHeight
    }
}

extension CategoryViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.categories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CategoryCell.Identifer, for: indexPath) as? CategoryCell else { return UITableViewCell() }
        let currentCategory = viewModel.categories[indexPath.row]
        cell.configureCell(for: CategoryCellViewModel(categoryName: currentCategory.categoryName,
                                                      isFirst: indexPath.row == 0,
                                                      isLast: indexPath.row == viewModel.categories.count - 1,
                                                      isSelected: currentCategory.id == selectedCategoryID))
        return cell
    }
}


//MARK: - UI config

private extension CategoryViewController {
    
   func setupUI() {
       view.addSubview(titleLabel)
       view.addSubview(emptyView)
       view.addSubview(tableView)
       view.addSubview(addButton)
       addConstraints()
    }
    
    func addConstraints() {
        
        let safeArea = view.safeAreaLayoutGuide
        let categoryOffset = Constants.CategoryViewControllerConstants.titleSpacing
        
        NSLayoutConstraint.activate([
        
            titleLabel.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: categoryOffset),
            titleLabel.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor),
            titleLabel.heightAnchor.constraint(equalToConstant: Constants.CategoryViewControllerConstants.titleHeight),
            
            tableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: categoryOffset),
            tableView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -categoryOffset),
            tableView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: categoryOffset),
            tableView.bottomAnchor.constraint(equalTo: addButton.topAnchor, constant: -categoryOffset),
            
            emptyView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: categoryOffset),
            emptyView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
            emptyView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor),
            emptyView.bottomAnchor.constraint(equalTo: addButton.topAnchor, constant: -categoryOffset),
            
            addButton.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: categoryOffset),
            addButton.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -categoryOffset),
            addButton.heightAnchor.constraint(equalToConstant: Constants.CategoryViewControllerConstants.buttonHeight),
            addButton.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor, constant: -categoryOffset)
        
        ])
        
    }
    
}
