# -*- coding: utf-8 -*-
class IssueTableViewCell < AMP::SmoothTableViewCell

  attr_accessor :dataSource

  CONTENT_WIDTH = 250
  
  def self.contentHeight(title)
    size = UIView.textContetSize(title, width:CONTENT_WIDTH, height:20000, font:UIFont.fontWithName("Helvetica", size:14), lineBreakMode:NSLineBreakByWordWrapping)    
    height = 30 + size.height + 20
    [height, 80].max
  end

  def layoutSubviews()
    self.contentView.frame = self.bounds
    self.imageView.frame = [[10, 30], [30, 30]]
  end

  def draw(rect)

    # comment
    UIColor.grayColor.setFill()
    commentsRect = [[230, 10], [rect.size.width, 10]]
    commentsFont ||= begin
      UIFont.fontWithName("Helvetica", size:12)
    end
    "#{@dataSource[:comments]} comments".drawInRect(commentsRect, withFont:commentsFont, lineBreakMode:NSLineBreakByWordWrapping)

    # time
    UIColor.grayColor.setFill()
    timeRect = [[10, 10], [rect.size.width, 10]]
    timeFont ||= begin
      UIFont.fontWithName("Helvetica", size:12)
    end
    date = AMP::Util.dateFormatter(@dataSource[:updated_at], "YYYY'-'MM'-'dd'T'HH':'mm':'ss'Z'", "YYYY-MM-dd HH:mm:ss")
    "##{@dataSource[:number]} - #{date}".drawInRect(timeRect, withFont:timeFont, lineBreakMode:NSLineBreakByWordWrapping)

    # title
    UIColor.blackColor.setFill()      
    titleRect = [[50, 30], [CONTENT_WIDTH, 80]]
    titleFont ||= begin
      UIFont.fontWithName("Helvetica", size:14)
    end
    @dataSource[:title].drawInRect(titleRect, withFont:titleFont, lineBreakMode:NSLineBreakByWordWrapping)

    # icon
    self.imageView.setImageWithURL(NSURL.URLWithString(@dataSource[:user][:avatar_url]), placeholderImage:nil)
  end
end