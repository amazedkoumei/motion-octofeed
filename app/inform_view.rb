# -*- coding: utf-8 -*-
class InformView < UIView

  attr_accessor :message, :image

  def init()
    if super
      width = 280
      height = 100
      x = (App.window.frame.size.width - width) / 2
      y = (App.window.frame.size.height - height) / 2 - 50
      self.frame = CGRectMake(x , y, width, height)
      self.backgroundColor = UIColor.colorWithWhite(0.0, alpha:0.5)
      self.alpha = 1.0
      self.layer.cornerRadius = 8.0
      self.layer.masksToBounds = true
      self.clipsToBounds = true

      @message = message

      @label = UILabel.new.tap do |l|
        l.frame = CGRectMake(0 , 60, 280, 30)
        l.textColor = UIColor.whiteColor
        l.textAlignment = NSTextAlignmentCenter
        l.font = UIFont.boldSystemFontOfSize(18.0)
        l.alpha = 1
        l.backgroundColor = UIColor.clearColor
        self.addSubview(l)
      end

      @indicator = UIActivityIndicatorView.new.tap do |i|
        i.initWithActivityIndicatorStyle(UIActivityIndicatorViewStyleWhiteLarge)
        i.frame = CGRectMake(0 , 10, 280, 50)
        i.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite
        i.backgroundColor = UIColor.clearColor
        self.addSubview(i)
      end

      self.hideWithAnimation(false)
    end
    self
  end

  def showWithAnimation(animated)
    @indicator.startAnimating()
    if animated
      context = UIGraphicsGetCurrentContext()
      UIView.beginAnimations(nil, context:context)
      UIView.setAnimationDuration(0.5)
      UIView.setAnimationDelegate(self)
      self.alpha = 1.0
      UIView.commitAnimations()
    else
      self.alpha = 1.0
    end
  end

  def hideWithAnimation(animated)
    if animated
      context = UIGraphicsGetCurrentContext()
      UIView.beginAnimations(nil, context:context)
      UIView.setAnimationDuration(0.5)
      UIView.setAnimationDelegate(self)
      self.alpha = 0
      UIView.commitAnimations()
    else
      self.alpha = 0
    end
    @indicator.stopAnimating()
  end

  def drawRect(rect)
    super
    @label.text = @message
  end
end