# -*- coding: utf-8 -*-
class IssueDetailTableViewCell < UITableViewCell

  attr_accessor :aContentView, :issue

  def initWithStyle(style, reuseIdentifier:reuseIdentifier)
    if super
      @aContentView = IssueDetailTableViewCellContentView.alloc.initWithFrame(self.contentView.frame, withCell:self)
      @aContentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight
      self.contentView.addSubview(@aContentView)
    end
    self
  end
end