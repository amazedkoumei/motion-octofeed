# -*- coding: utf-8 -*-
class IssueDetailCommentTableViewCell < UITableViewCell

  attr_accessor :aContentView, :comment

  def initWithStyle(style, reuseIdentifier:reuseIdentifier)
    if super
      @aContentView = IssueDetailCommentTableViewCellContentView.alloc.initWithFrame(self.contentView.frame, withCell:self)
      @aContentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight
      self.contentView.addSubview(@aContentView)
    end
    self
  end
end