# -*- coding: utf-8 -*-
class MainTableViewCell < AMP::SmoothTableViewCell

  attr_accessor :dataSource

  def draw(rect)
    if(!@dataSource.nil?)
      UIColor.blackColor.setFill()      
      titleRect = rect
      titleRect.origin.x = 50
      titleRect.origin.y = 30
      titleRect.size.height = 80
      titleRect.size.width = 250;
      @titleFont ||= begin
        UIFont.fontWithName("Helvetica", size:14)
      end
      @dataSource[:title].drawInRect(titleRect, withFont:@titleFont, lineBreakMode:NSLineBreakByWordWrapping)

      UIColor.grayColor.setFill()      
      timeRect = rect;
      timeRect.origin.x = 250
      timeRect.origin.y = 10
      timeRect.size.height = 10
      timeRect.size.width = rect.size.width - 20;
      @timeFont ||= begin
        UIFont.fontWithName("Helvetica", size:12)
      end
      @dataSource[:time].drawInRect(timeRect, withFont:@timeFont, lineBreakMode:NSLineBreakByWordWrapping)




      # FIXME: DRY: MainTableViewController.fetchFeed()
      # input > https://secure.gravatar.com/avatar/[:fileName]?s=30&;d=[:original image url]
      /.+?\/avatar\/(.+?)\?s=30.*/ =~ @dataSource[:thumbnail]
      fileName = $1 + ".png"
      fileManager = NSFileManager.defaultManager()
      filePath = "#{App.documents_path}/#{fileName}"
      if fileManager.fileExistsAtPath(filePath)
        if @dataSource[:thumbnailImage].nil?
          @dataSource[:thumbnailImage] = UIImage.imageWithContentsOfFile(filePath)
        end          
        @img_rect = rect;
        @img_rect.origin.x = 0;
        @img_rect.origin.y = 0;
        @img_rect.size.height = 30
        @img_rect.size.width = 30
        UIGraphicsBeginImageContext(@img_rect.size);
        @dataSource[:thumbnailImage].drawInRect(@img_rect)
        @dataSource[:thumbnailImage] = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        @dataSource[:thumbnailImage].drawAtPoint(CGPointMake(10, 30))
      else
        # reason of calling Dispatch::Queue is that other thread is downloading images
        Dispatch::Queue.concurrent.async{
          self.setNeedsDisplay()
        }
      end
    end
  end
end