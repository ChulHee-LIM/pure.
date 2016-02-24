class Advertisement < ActiveRecord::Base
	belongs_to :cafe
	belongs_to :user
	has_one :payinfo
end
