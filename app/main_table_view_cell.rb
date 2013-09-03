# -*- coding: utf-8 -*-
class MainTableViewCell < AMP::SmoothTableViewCell

  attr_accessor :dataSource

  CONTENT_WIDTH = 250
  # FIXME: make CONST
  #CONTENT_FONT = UIFont.systemFontOfSize(14)
  #CONTENT_LINE_BREAK_MODE = NSLineBreakByWordWrapping

  def self.contentHeight(title)
    size = UIView.textContetSize(title, width:CONTENT_WIDTH, height:20000, font:UIFont.systemFontOfSize(14), lineBreakMode:NSLineBreakByWordWrapping)    
    height = 30 + size.height + 20
  end

  def layoutSubviews()
    self.contentView.frame = self.bounds
    self.imageView.frame = [[10, 30], [30, 30]]
  end

  def draw(rect)
    if(!@dataSource.nil?)

      # prevent bleeding
      context = UIGraphicsGetCurrentContext()
      self.layer.contentsScale = UIScreen.mainScreen.scale

      # title
      UIColor.blackColor.setFill()
      titleRect = [[50, 30], [CONTENT_WIDTH, 80]]
      titleFont ||= begin
        UIFont.fontWithName("Helvetica", size:14)
      end
      @dataSource[:title].drawInRect(titleRect, withFont:titleFont, lineBreakMode:NSLineBreakByWordWrapping)

      # type
      /<!--(.+?)-->/ =~ @dataSource[:content]
      type = $1.strip.gsub(/_/, " ")
      typeRect = [[10, 10], [CONTENT_WIDTH - (320 - CONTENT_WIDTH), 10]]
      @typeFont ||= begin
        UIFont.fontWithName("Helvetica-Bold", size:12)
      end
      "[#{type}]".drawInRect(typeRect, withFont:@typeFont, lineBreakMode:NSLineBreakByWordWrapping)
      
      # time
      UIColor.grayColor.setFill()
      timeRect = [[CONTENT_WIDTH, 10], [320 - CONTENT_WIDTH, 10]]
      @timeFont ||= begin
        UIFont.fontWithName("Helvetica", size:12)
      end
      @dataSource[:time].drawInRect(timeRect, withFont:@timeFont, lineBreakMode:NSLineBreakByWordWrapping)

      # icon
      # FIXME: DRY: MainTableViewController.fetchFeed()
      # input > https://secure.gravatar.com/avatar/[:fileName]?s=30&;d=[:original image url]
      self.imageView.setImageWithURL(NSURL.URLWithString(@dataSource[:thumbnail]), placeholderImage:nil)
      #p "title: #{@dataSource[:title]} thumb: #{@dataSource[:thumbnail]}"
    end
  end

end