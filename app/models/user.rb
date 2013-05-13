class User < ActiveRecord::Base
  rolify
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :invitable, :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  devise :omniauthable, :omniauth_providers => [:facebook]

  # Setup accessible (or protected) attributes for your model
  attr_accessible :role_ids, :as => :admin
  attr_accessible :name, :email, :password, :password_confirmation, :remember_me
  attr_accessible :provider, :uid

  has_many :gcm_devices, :class_name => Gcm::Device

  has_many :stock_firms, :through => :user_favorite_stock_firms

  #def send_message title, message
  #  push_message = PushMessage.create(:title => title, :message => message)
  #  push_message.gcm_devices << device
  #
  #  self.gcm_devices.each do |gcm_device|
  #    notification = Gcm::Notification.new
  #    notification.device = gcm_device
  #    notification.collapse_key = "updates_available"
  #    notification.delay_while_idle = false
  #    notification.data = {:registration_ids => ["#{gcm_device.registration_id}"], :data => {:message_text => message, :title_text => title, :notification_id => push_message.id}}
  #    notification.save!
  #    #puts notification.data
  #  end
  #  Gcm::Notification.send_notifications
  #end
  def self.new_with_session(params, session)
    super.tap do |user|
      if data = session["devise.facebook_data"] && session["devise.facebook_data"]["extra"]["raw_info"]
        user.email = data["email"] if user.email.blank?
      end
    end
  end
end

def self.find_for_facebook_oauth(auth, signed_in_resource=nil)
  user = User.where(:provider => auth.provider, :uid => auth.uid).first
  unless user
    user = User.create(name:auth.extra.raw_info.name,
                       provider:auth.provider,
                       uid:auth.uid,
                       email:auth.info.email,
                       password:Devise.friendly_token[0,20]
    )
  end
  user
end

