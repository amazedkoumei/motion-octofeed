# -*- coding: utf-8 -*-
class NewsfeedTableViewCell < AMP::SmoothTableViewCell

  attr_accessor :dataSource

  def self.contentHeight(title)
    # 文字列を受けとって高さを計算するのが一般的
    # なので引数はうけとる形にしておく
    # UIView.textContetSize(title, width:CONTENT_WIDTH, height:20000, font:UIFont.systemFontOfSize(14), lineBreakMode:NSLineBreakByWordWrapping).height 
    110
  end

  def layoutSubviews()
    self.contentView.frame = self.bounds
    self.imageView.frame = [[10, 10], [50, 50]]

    # activity icon (Web Font)
    UILabel.new.tap do |l|
      origin_x = 10 + self.imageView.frame.origin.x + self.imageView.frame.size.width
      origin_y = 50
      l.frame = [[origin_x, origin_y],[32, 32]]
      l.setFont(UIFont.fontWithName("octicons", size:24))
      l.setText(@dataSource[:activity_icon])
      l.textColor = "#bbb".to_color
      self.contentView.addSubview(l)
    end
  end

  def content_width
    self.frame.size.width - 70
  end

  def draw(rect)
    if(!@dataSource.nil?)

      # prevent bleeding
      context = UIGraphicsGetCurrentContext()
      self.layer.contentsScale = UIScreen.mainScreen.scale

      origin_x = self.imageView.frame.origin.x + self.imageView.frame.size.width + 10

      title1Rect = [[origin_x, 10], [content_width, 300]]
      self.drawTitle1(title1Rect)

      title2Rect = [[origin_x, 30], [content_width, 300]]
      self.drawTitle2(title2Rect)

      descriptionRect = [[origin_x + 30, 60], [content_width - 30, 30]]
      self.drawDescription(descriptionRect)

      timeRect = [[content_width, 90], [70, 30]]
      self.drawTime(timeRect)

      # icon
      self.imageView.setImageWithURL(NSURL.URLWithString(@dataSource[:avatar_url]), placeholderImage:nil)
    end
  end

  def drawTitle1(rect)
    # TODO: もしかしたら折り返さないかもしれない
    # (NSParagraphStyleAttributeName の style がきかない可能性がある)
    NSMutableAttributedString.new.tap do |title1|
      # 主語
      title1.initWithString(@dataSource[:title_subject] + " ", attributes:{
        NSFontAttributeName => UIFont.fontWithName("Helvetica-Bold", size:16),
        NSForegroundColorAttributeName => "#4183c4".to_color
      })
      # 述語
      predicate = NSMutableAttributedString.new.tap do |s|
        s.initWithString(@dataSource[:title_predicate], attributes:{
          NSFontAttributeName => UIFont.fontWithName("Helvetica-Bold", size:14),
          NSForegroundColorAttributeName => UIColor.blackColor
        })
      end

      # 主語 + 述語
      title1.appendAttributedString(predicate)

      style = NSParagraphStyle.defaultParagraphStyle.mutableCopy.tap do |s|
        s.setLineBreakMode(NSLineBreakByTruncatingTail)
      end

      title1.drawInRect(rect, withAttributes: {
        NSParagraphStyleAttributeName => style
      })        
    end
  end

  def drawTitle2(rect)
    # 目的語 
    title2 = @dataSource[:title_object]

    style = NSParagraphStyle.defaultParagraphStyle.mutableCopy.tap do |s|
      s.setLineBreakMode(NSLineBreakByTruncatingTail)
    end

    title2.drawInRect(rect, withAttributes: {
      NSFontAttributeName => UIFont.fontWithName("Helvetica-Bold", size:16),
      NSForegroundColorAttributeName => "#4183c4".to_color,
      NSParagraphStyleAttributeName => style
    })        
  end

  def drawDescription(rect)
    description = @dataSource[:title_description].strip

    style = NSParagraphStyle.defaultParagraphStyle.mutableCopy.tap do |s|
      s.setLineBreakMode(NSLineBreakByWordWrapping)
    end

    description.drawInRect(rect, withAttributes: {
      NSFontAttributeName => UIFont.fontWithName("Helvetica", size:12),
      NSForegroundColorAttributeName => "#666".to_color,
      NSParagraphStyleAttributeName => style
    })
  end

  def drawTime(rect)
    time = @dataSource[:time]

    time.drawInRect(rect, withAttributes: {
      NSFontAttributeName => UIFont.fontWithName("Helvetica", size:12),
      NSForegroundColorAttributeName => "#bbb".to_color,
    })
  end
end