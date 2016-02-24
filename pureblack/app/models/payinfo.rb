class Payinfo < ActiveRecord::Base
	belongs_to :user
	belongs_to :cafe
	belongs_to :product
	has_one :advertisement
end
