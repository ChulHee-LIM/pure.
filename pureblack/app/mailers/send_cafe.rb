class SendCafe < ApplicationMailer
    def cafemailer cafe_mail, title_mail, content_mail, imgfile
        mail from:cafe_mail, 
               to: 'yhs930709@gmail.com', 
          subject:title_mail, 
             body:content_mail
        mail.attachments[imgfile.original_filename] = imgfile.read
        #attachments:imgfile     
        # attachments:imgfile
        # mail.attachments[imgfile] = imgfile.read('/path/to/imgfile')
        # attachments["hi"] = imgfile.read
        #mail.attachments[imgfile] = imgfile
    end
end
