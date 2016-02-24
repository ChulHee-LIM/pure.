class Tag < ActiveRecord::Base
    belongs_to :cafe
    has_and_belongs_to_many :users
    belongs_to :post
end
