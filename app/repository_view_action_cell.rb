# -*- coding: utf-8 -*-
class RepsitoryViewActionCell < UITableViewCell

  attr_accessor :iconLabel

  def initWithStyle(style, reuseIdentifier:reuseIdentifier)
    super

    self.selectionStyle = UITableViewCellSelectionStyleBlue
    self.accessoryType = UITableViewCellAccessoryNone

    self.textLabel.font = UIFont.boldSystemFontOfSize(18)

    self.iconLabel = UILabel.new.tap do |l|
      l.textColor = "#bbb".to_color
      l.font = UIFont.fontWithName("octicons", size:24)
      l.textAlignment = UITextAlignmentCenter
      self.addSubview(l)
    end

    self
  end

  def layoutSubviews()
    self.iconLabel.frame = [[76, 0], [44, 44]]
    self.textLabel.frame = [[140, 0], [320, 44]]
  end

end