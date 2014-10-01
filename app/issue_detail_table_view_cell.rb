# -*- coding: utf-8 -*-
class IssueDetailTableViewCell < AMP::SmoothTableViewCell

  attr_accessor :dataSource

  content_width = 250

  def layoutSubviews()
    self.contentView.frame = self.bounds
    self.imageView.frame = [[10, 35], [30, 30]]
  end

  def content_width
    self.frame.size.width - 70
  end

  def draw(rect)

    # comment
    UIColor.grayColor.setFill()
    commentsRect = [[10, 10], [rect.size.width - 20, 10]]
    @commentsFont ||= begin
      UIFont.fontWithName("Helvetica", size:12)
    end
    "#{@dataSource[:user][:login]}".drawInRect(commentsRect, withFont:@commentsFont, lineBreakMode:NSLineBreakByWordWrapping)

    # time
    UIColor.grayColor.setFill()
    timeRect = [[content_width - 60, 10], [rect.size.width - 20, 10]]
    @timeFont ||= begin
      UIFont.fontWithName("Helvetica", size:12)
    end
    date = AMP::Util.dateFormatter(@dataSource[:updated_at], "YYYY'-'MM'-'dd'T'HH':'mm':'ss'Z'", "YYYY-MM-dd HH:mm:ss")
    "#{date}".drawInRect(timeRect, withFont:@timeFont, lineBreakMode:NSLineBreakByWordWrapping)

    # title
    UIColor.blackColor.setFill()      
    @titleFont ||= begin
      UIFont.fontWithName("Helvetica", size:14)
    end

    size = UIView.textContetSize(@dataSource[:body], width:content_width, height:20000, font:@titleFont, lineBreakMode:NSLineBreakByWordWrapping)    
    height = [size.height, 80].max
    titleRect = [[50, 30], [content_width, height]]

    @dataSource[:body].drawInRect(titleRect, withFont:@titleFont, lineBreakMode:NSLineBreakByWordWrapping)

    # icon
    self.imageView.setImageWithURL(NSURL.URLWithString(@dataSource[:user][:avatar_url]), placeholderImage:nil)
  end
end