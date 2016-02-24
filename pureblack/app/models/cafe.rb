class Cafe < ActiveRecord::Base
    
    belongs_to :user
    
    has_many :posts, dependent: :destroy
    has_many :tags, dependent: :destroy
    has_many :payinfos, dependent: :destroy
    has_many :advertisements, dependent: :destroy
    has_many :products, dependent: :destroy
    mount_uploader :image,CafeimageuploaderUploader
    mount_uploader :thumnail,CafeimageuploaderUploader

    geocoded_by :address
    after_validation :geocode
    def avg
        total = 0
        post_count = 0
        id = Cafe.where(user_id:user.id).take.user_id
        posts.each do |c|
            total += c.score
        end
        post_count=posts.count-posts.where(user_id: id).count
        if user.id == id
            if post_count == 0
                0
            else
                total.to_f / post_count
            end
        else
            if post_count == 0
                0
            else
                total.to_f / post_count
            end
        end
    end
end
