class Logo < ActiveRecord::Base
	mount_uploader :index,CafeimageuploaderUploader
    mount_uploader :other,CafeimageuploaderUploader
end
