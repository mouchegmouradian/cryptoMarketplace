//
//  MarketItemCell.swift
//  CryptoMarketplace
//

import UIKit
import RxSwift
import Rswift

class MarketItemCell: UITableViewCell {

    // MARK: Properties

    private lazy var containerView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false

        v.backgroundColor = .white
        v.layer.cornerRadius = 20
        v.layer.shadowColor = UIColor.gray.cgColor
        v.layer.shadowOpacity = 1
        v.layer.shadowOffset = .zero
        v.layer.masksToBounds = false

        v.layer.shouldRasterize = true
        v.layer.rasterizationScale = UIScreen.main.scale

        return v
    }()
    private lazy var dataStatusIndicatorView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false

        v.backgroundColor = .clear
        v.layer.cornerRadius = 2

        return v
    }()
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 1
        label.textAlignment = .left
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 18, weight: .bold)

        return label
    }()
    private lazy var symbolLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 1
        label.textAlignment = .left
        label.textColor = .gray
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)

        return label
    }()
    private lazy var priceLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 1
        label.textAlignment = .right
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 18, weight: .bold)

        return label
    }()
    private lazy var priceChangeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 1
        label.textAlignment = .right
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)

        return label
    }()

    // MARK: Lifecycle

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        selectionStyle = .none

        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func drawShadows() {
        containerView.layer.shadowPath = UIBezierPath(roundedRect: containerView.bounds, cornerRadius: containerView.layer.cornerRadius).cgPath
    }

    func setup(data: MarketTicker) {
        nameLabel.text = data.info.first.name
        symbolLabel.text = data.info.first.realSymbol
        priceLabel.text = data.ticker.lastPrice.formatted(.currency(code: data.info.second.realSymbol))
        priceChangeLabel.text = String(format: "%+.2f%%", data.ticker.dailyChangeRelative * 100)

        if (data.ticker.dailyChangeRelative < 0) {
            priceChangeLabel.textColor = .red
        } else if (data.ticker.dailyChangeRelative > 0) {
            priceChangeLabel.textColor = .green
        } else {
            priceChangeLabel.textColor = .gray
        }

        switch data.status {
        case .none: dataStatusIndicatorView.backgroundColor = .clear
        case .upToDate: dataStatusIndicatorView.backgroundColor = .green
        case .outdated: dataStatusIndicatorView.backgroundColor = .orange
        }
    }
}

// MARK: - Private

private extension MarketItemCell {

    func setupUI() {
        self.backgroundColor = .white

        // containers

        contentView.addSubview(containerView)

        containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8).isActive = true
        containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8).isActive = true
        containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16).isActive = true
        containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16).isActive = true
        containerView.heightAnchor.constraint(equalToConstant: 90).isActive = true

        containerView.addSubview(nameLabel)
        containerView.addSubview(symbolLabel)
        containerView.addSubview(priceLabel)
        containerView.addSubview(dataStatusIndicatorView)
        containerView.addSubview(priceChangeLabel)

        nameLabel.bottomAnchor.constraint(equalTo: containerView.centerYAnchor, constant: -5).isActive = true
        nameLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20).isActive = true

        symbolLabel.topAnchor.constraint(equalTo: containerView.centerYAnchor, constant: 5).isActive = true
        symbolLabel.leadingAnchor.constraint(greaterThanOrEqualTo: nameLabel.leadingAnchor).isActive = true

        priceLabel.bottomAnchor.constraint(equalTo: containerView.centerYAnchor, constant: -5).isActive = true
        priceLabel.leadingAnchor.constraint(greaterThanOrEqualTo: nameLabel.trailingAnchor, constant: 20).isActive = true
        priceLabel.trailingAnchor.constraint(equalTo: dataStatusIndicatorView.leadingAnchor, constant: -4).isActive = true

        dataStatusIndicatorView.centerYAnchor.constraint(equalTo: priceLabel.centerYAnchor).isActive = true
        dataStatusIndicatorView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20).isActive = true
        dataStatusIndicatorView.widthAnchor.constraint(equalToConstant: 4).isActive = true
        dataStatusIndicatorView.heightAnchor.constraint(equalTo: dataStatusIndicatorView.widthAnchor).isActive = true

        priceChangeLabel.topAnchor.constraint(equalTo: containerView.centerYAnchor, constant: 5).isActive = true
        priceChangeLabel.leadingAnchor.constraint(greaterThanOrEqualTo: nameLabel.trailingAnchor, constant: 20).isActive = true
        priceChangeLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20).isActive = true
    }
}
