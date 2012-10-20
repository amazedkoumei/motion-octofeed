# -*- coding: utf-8 -*-
class MainTableViewCellContentView < UIView

  attr_accessor :highlighted, :cell

  def initialize
    @highlighted = false
    @cell = nil
  end

  def initWithFrame(frame, withCell:newCell)
    if super
      @cell = newCell;
      self.setBackgroundColor(UIColor.clearColor);
    end
    self;
  end 

  def setHighlighted(newValue)
    @highlighted = newValue;
  end

  def drawRect(rect)
    if(!@cell.nil? && !@cell.feed.nil?)
      titleRect = rect
      titleRect.origin.x = 50
      titleRect.origin.y = 30
      titleRect.size.height = 80
      titleRect.size.width = 250;
      @cell.feed[:title].drawInRect(titleRect, withFont:UIFont.boldSystemFontOfSize(18.0), lineBreakMode:NSLineBreakByWordWrapping)
      
      timeRect = rect;
      timeRect.origin.x = 250
      timeRect.origin.y = 10
      timeRect.size.height = 10
      timeRect.size.width = rect.size.width - 20;
      @cell.feed[:time].drawInRect(timeRect, withFont:UIFont.boldSystemFontOfSize(12.0), lineBreakMode:NSLineBreakByWordWrapping)

      if @cell.feed[:thumbnailImage].nil?
        @image_rect = rect
        Dispatch::Queue.concurrent.async{
          thumbnailData = NSData.dataWithContentsOfURL(NSURL.URLWithString(@cell.feed[:thumbnail]))
          @cell.feed[:thumbnailImage] = UIImage.alloc.initWithData(thumbnailData)
          self.setNeedsDisplay()
        }
      else
        img_rect = rect;
        img_rect.origin.x = 0;
        img_rect.origin.y = 0;
        img_rect.size.height = 30
        img_rect.size.width = 30
        UIGraphicsBeginImageContext(img_rect.size);
        @cell.feed[:thumbnailImage].drawInRect(img_rect)
        @cell.feed[:thumbnailImage] = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        @cell.feed[:thumbnailImage].drawAtPoint(CGPointMake(10, 30))
      end
    end
  end
end