# -*- coding: utf-8 -*-
class MainTableViewCell < UITableViewCell

  attr_accessor :aContentView, :feed

  def initWithStyle(style, reuseIdentifier:reuseIdentifier)
    if super
      @aContentView = MainTableViewCellContentView.alloc.initWithFrame(self.contentView.frame, withCell:self)
      @aContentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight
      self.contentView.addSubview(@aContentView)
    end
    self
  end
end