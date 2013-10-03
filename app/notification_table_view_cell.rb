# -*- coding: utf-8 -*-
class NotificationTableViewCell < AMP::SmoothTableViewCell

  attr_accessor :dataSource

  CONTENT_WIDTH = 230

  def self.contentHeight(title)
    size = UIView.textContetSize(title, width:CONTENT_WIDTH, height:20000, font:UIFont.fontWithName("Helvetica", size:14), lineBreakMode:NSLineBreakByWordWrapping)    
    height = 30 + size.height + 20
    [height, 80].max
  end

  def draw(rect)

    # type
    UIColor.grayColor.setFill()
    typeFont ||= begin
      UIFont.fontWithName("Helvetica", size:12)
    end
    type = notificationType(@dataSource[:subject][:url])
    typeSize = UIView.textContetSize(type, width:CONTENT_WIDTH, height:20000, font:typeFont, lineBreakMode:NSLineBreakByWordWrapping)
    typeRect = [[320 - typeSize.width - 35, 10], [typeSize.width, 10]]
    "#{type}".drawInRect(typeRect, withFont:typeFont, lineBreakMode:NSLineBreakByWordWrapping)

    # time
    UIColor.grayColor.setFill()
    timeRect = [[10, 10], [rect.size.width, 10]]
    timeFont ||= begin
      UIFont.fontWithName("Helvetica", size:12)
    end
    date = AMP::Util.dateFormatter(@dataSource[:updated_at], "YYYY'-'MM'-'dd'T'HH':'mm':'ss'Z'", "YYYY-MM-dd HH:mm:ss")
    "#{date}".drawInRect(timeRect, withFont:timeFont, lineBreakMode:NSLineBreakByWordWrapping)

    # title
    UIColor.blackColor.setFill() 
    titleRect = [[50, 30], [CONTENT_WIDTH, 80]]
    titleFont ||= begin
      UIFont.fontWithName("Helvetica", size:14)
    end
    @dataSource[:subject][:title].drawInRect(titleRect, withFont:titleFont, lineBreakMode:NSLineBreakByWordWrapping)

    # unread mark
    if @dataSource[:unread]
      "#000099".to_color.setFill()
      unreadRect = [[15, 30], [30, 30]]
      unreadFont ||= begin
        UIFont.fontWithName("Helvetica", size:18)
      end
      "●".drawInRect(unreadRect, withFont:unreadFont, lineBreakMode:NSLineBreakByWordWrapping)
    end
    
  end

  # FIXME: it may be better in github_manager.rb
  def notificationType(url)
    url =~ /https?:\/\/.+?\/.+?\/.+?\/.+?\/(.+?)\/.*/
    $1
  end

end