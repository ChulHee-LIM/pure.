class Post < ActiveRecord::Base
	belongs_to :cafe
	belongs_to :user
	has_many :replies, dependent: :destroy
	has_many :tags, dependent: :destroy
	has_many :likes, dependent: :destroy

	mount_uploader :image,CafeimageuploaderUploader
end
