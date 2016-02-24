class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :omniauthable, :omniauth_providers => [:facebook]
         
  has_many :caves ,dependent: :destroy
  has_and_belongs_to_many :tags
  has_many :posts ,dependent: :destroy
  has_many :payinfos ,dependent: :destroy
  has_many :replies, dependent: :destroy
  has_many :advertisements, dependent: :destroy
  has_many :products, dependent: :destroy
  has_many :orderinfos, dependent: :destroy
  has_many :likes, dependent: :destroy

  mount_uploader :image,CafeimageuploaderUploader
  acts_as_follower
  acts_as_followable

  def self.find_for_facebook_oauth(auth)
      user = User.where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
      user.provider = auth.provider
      user.uid = auth.uid
      
      if auth.info.email.nil?
        
        user.email =auth.uid+"@phone.com"
      else
        
        user.email = auth.info.email
      end  
      user.password = Devise.friendly_token[0,20]
      user.name = auth.info.name   # assuming the user model has a name
      user.image = auth.info.image # assuming the user model has an image
      
    end
  
      end
  def self.find_for_facebook_oauth(auth)
    user = where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
      user.provider = auth.provider
      user.uid = auth.uid
      if auth.info.email.nil?
        
        user.email =auth.uid+"@phone.com"
      else
        
        user.email = auth.info.email
      end
      user.password = Devise.friendly_token[0,20]
      user.name = auth.info.name   # assuming the user model has a name
      user.image = auth.info.image # assuming the user model has an image
    end
  
    
  end


end