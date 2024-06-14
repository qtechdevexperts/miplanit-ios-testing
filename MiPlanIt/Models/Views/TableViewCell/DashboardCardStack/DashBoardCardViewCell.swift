
import UIKit

protocol DashBoardCardViewCellDelegate: class {
    func dashBoardCardViewCell(_ dashBoardCardViewCell: DashBoardCardViewCell, selectedItem: Any)
    func dashBoardCardViewCell(_ dashBoardCardViewCell: DashBoardCardViewCell, expandCard card: CardView)
    func dashBoardCardViewCell(_ dashBoardCardViewCell: DashBoardCardViewCell, openOverDue card: CardView)
}

class DashBoardCardViewCell: CardStackViewCell {

    
    private struct Constants {
        static let cellCornerRadius: CGFloat = 12
        static let animationSpeed: Float = 0.86
        static let rotationRadius: CGFloat = 15
        static let smileNeutral = "smile_neutral"
        static let smileFace1 = "smile_face_1"
        static let smileFace2 = "smile_face_2"
        static let smileRotten1 = "smile_rotten_1"
        static let smileRotten2 = "smile_rotten_2"

    }
    
    var cardView: CardView!
    weak var delegate: DashBoardCardViewCellDelegate?
    
    @IBOutlet weak var text: UILabel!
    @IBOutlet private weak var voteSmile: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var viewContainer: UIView!
    @IBOutlet weak var labelCardName: UILabel!
    @IBOutlet weak var constraintContainerWidth: NSLayoutConstraint!
    @IBOutlet weak var viewExpandButton: UIView!
    @IBOutlet weak var labelNoItem: UILabel!
    @IBOutlet weak var viewProcessing: UIView!
    @IBOutlet weak var viewBGGradient: UIView?
    @IBOutlet weak var activityIndicatorProcessing: UIActivityIndicatorView!
    @IBOutlet weak var buttonForImage: UIButton!
    @IBOutlet weak var buttonForOverdue: UIButton!
    @IBOutlet weak var labelForOverdueCount: UILabel!
    
    //MARK: - IBActions
    @IBAction func overdueCountButtonClicked(_ sender: UIButton) {
        self.delegate?.dashBoardCardViewCell(self, openOverDue: self.cardView)
    }
    @IBAction func expandButtonClicked(_ sender: UIButton) {
        self.delegate?.dashBoardCardViewCell(self, expandCard: self.cardView)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        layer.cornerRadius = Constants.cellCornerRadius
        clipsToBounds = false
    }
    
    override var center: CGPoint {
        didSet {
            //updateSmileVote()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.viewBGGradient?.frame = contentView.frame
        self.updateBgGradient(color1: cardView.dashboardCard.bgColorCode.getColor(), color2: cardView.dashboardCard.bgColorCode2.getColor())
    }
    
    override internal func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        super.apply(layoutAttributes)
    }
    
    func configCell(cardView: CardView, index: IndexPath, delegate: DashBoardCardViewCellDelegate, updateType: DashBoardTitle?) {
        self.labelForOverdueCount.isHidden = true
        self.buttonForOverdue.isHidden = true
        self.cardView = cardView
        self.viewContainer.bordorColor = cardView.dashboardCard.borderColorCode.getColor()
        self.viewExpandButton.backgroundColor = cardView.dashboardCard.titleColor.getColor()
        var iconName = "eventIconnew"
        switch cardView.dashboardCard.dashBoardTitle {
        case .event:
            self.labelCardName.text = "Events"
            self.labelNoItem.text = Message.noEventDashboard(cardView.activeDateSection)
            iconName = "eventIconnew"
        case .shopping:
            self.labelCardName.text = "Shopping"
            self.labelNoItem.text = Message.noItemsDashboard(cardView.activeDateSection)
            iconName = "shoppingIconnew"
        case .toDo:
            self.labelCardName.text = "To Do"
            self.labelNoItem.text = Message.noItemsDashboard(cardView.activeDateSection)
            iconName = "todoIconnew"
            self.updateOverDueDataCountOfTodo()
        case .giftCard:
            self.labelCardName.text = "Coupons & Gifts"
            self.labelNoItem.text = Message.noItemsDashboard(cardView.activeDateSection)
            iconName = "giftCardIconnew"
        case .purchase:
            self.labelCardName.text = "Receipts & Bills"
            self.labelNoItem.text = Message.noItemsDashboard(cardView.activeDateSection)
            iconName = "purchaseIconNew"
        case .none:
            self.labelCardName.text = Strings.empty
        }
        self.labelCardName.textColor = cardView.dashboardCard.titleColor.getColor()
        self.delegate = delegate
        self.constraintContainerWidth.constant = self.getCardWidth(on: index)
        self.labelNoItem.textColor = cardView.dashboardCard.titleColor.getColor()
        self.viewProcessing.backgroundColor = cardView.dashboardCard.bgColorCode.getColor()
        self.buttonForImage.setImage(UIImage(named: iconName), for: .normal)
        self.updateItemsDataList(updateType)
    }
    
    func updateOverDueDataCountOfTodo() {
        self.labelForOverdueCount.isHidden = self.cardView.overDueData.isEmpty
        self.buttonForOverdue.isHidden = self.cardView.overDueData.isEmpty
        self.labelForOverdueCount.text = "\(self.cardView.overDueData.count)"
    }
    
    func updateItemsDataList(_ updateType: DashBoardTitle?) {
        let initialCount = self.tableView.numberOfRows(inSection: 0)
        self.tableView.isHidden = self.cardView.cardItemData.isEmpty
        self.labelNoItem.isHidden = !self.cardView.cardItemData.isEmpty
        self.viewProcessing.isHidden = !cardView.isProcessing
        self.viewProcessing.isHidden ? self.activityIndicatorProcessing.stopAnimating() : self.activityIndicatorProcessing.startAnimating()
        self.tableView.reloadData()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.scrollToPosition(updateType, refreshNeeded: initialCount == 0 && !self.cardView.cardItemData.isEmpty)
        }
    }
    
    func updateBgGradient(color1 : UIColor?, color2 : UIColor?) {
        if let colour1 = color1, let colour2 = color2 {
            self.viewBGGradient?.createGradientLayer(colours: [colour1, colour2], locations: nil,startPOint: CGPoint(x: 0.5, y: 0.0), endPoint: CGPoint(x: 0.5, y: 1.0))
        }
    }
    
    func scrollToPosition(_ updateType: DashBoardTitle?, refreshNeeded: Bool) {
        guard self.cardView.activeDateSection == .today, let updateTypeValue = updateType, refreshNeeded else { return }
        if let object = self.cardView.cardItemData as? [DashboardEventItem], updateTypeValue == .event {
            let totalCells = self.tableView.numberOfRows(inSection: 0)
            if let index = object.firstIndex(where: { (item) -> Bool in
                item.start >= Date()
            }), index < totalCells {
                self.tableView.scrollToRow(at: IndexPath(row: index, section: 0), at: .top, animated: true)
            }
            else if let index = object.firstIndex(where: { (item) -> Bool in
                item.end >= Date() && !item.isAllDay
            }), index < totalCells {
                self.tableView.scrollToRow(at: IndexPath(row: index, section: 0), at: .top, animated: true)
            }
            else if totalCells > 0 {
                self.tableView.scrollToRow(at: IndexPath(row: totalCells - 1, section: 0), at: .top, animated: true)
            }
        }
        else if let object = self.cardView.cardItemData as? [DashboardToDoItem], updateTypeValue == .toDo {
            if let index = object.firstIndex(where: { (item) -> Bool in
                item.initialDate == Date().initialHour()
            }), index < self.tableView.numberOfRows(inSection: 0) {
                self.tableView.scrollToRow(at: IndexPath(row: index, section: 0), at: .top, animated: true)
            }
        }
        else if let object = self.cardView.cardItemData as? [DashboardShopListItem], updateTypeValue == .shopping {
            if let index = object.firstIndex(where: { (item) -> Bool in
                item.duedate.initialHour() == Date().initialHour()
            }), index < self.tableView.numberOfRows(inSection: 0) {
                self.tableView.scrollToRow(at: IndexPath(row: index, section: 0), at: .top, animated: true)
            }
        }
        else if let object = self.cardView.cardItemData as? [DashboardPurchaseItem], updateTypeValue == .purchase {
            if let index = object.firstIndex(where: { (item) -> Bool in
                item.createdDate.initialHour() == Date().initialHour()
            }), index < self.tableView.numberOfRows(inSection: 0) {
                self.tableView.scrollToRow(at: IndexPath(row: index, section: 0), at: .top, animated: true)
            }
        }
        else if let object = self.cardView.cardItemData as? [DashboardGiftItem], updateTypeValue == .giftCard {
            if let index = object.firstIndex(where: { (item) -> Bool in
                item.createdDate.initialHour() == Date().initialHour()
            }), index < self.tableView.numberOfRows(inSection: 0) {
                self.tableView.scrollToRow(at: IndexPath(row: index, section: 0), at: .top, animated: true)
            }
        }
    }
    
    func getCardWidth(on index: IndexPath) -> CGFloat {
        self.viewExpandButton.alpha = 0.0
        switch index.row {
        case 1:
            return self.frame.width*0.95
        case 2:
            return self.frame.width*0.90
        case 3:
            return self.frame.width*0.85
        case 4:
            return self.frame.width*0.80
        default:
            self.viewExpandButton.alpha = 1.0
            return self.frame.width
        }
    }
}


