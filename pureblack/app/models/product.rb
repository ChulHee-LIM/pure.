class Product < ActiveRecord::Base
	belongs_to :cafe
	has_many :users, dependent: :destroy
	has_many :payinfos, dependent: :destroy
end
