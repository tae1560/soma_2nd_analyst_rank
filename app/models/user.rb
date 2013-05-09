class User < ActiveRecord::Base
  rolify
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :invitable, :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :role_ids, :as => :admin
  attr_accessible :name, :email, :password, :password_confirmation, :remember_me
  attr_accessible :provider, :uid

  has_many :gcm_devices, :class_name => Gcm::Device

  has_many :stock_firms, :through => :user_favorite_stock_firms

  def send_message title, message
    self.gcm_devices.each do |gcm_device|
      notification = Gcm::Notification.new
      notification.device = gcm_device
      notification.collapse_key = "updates_available"
      notification.delay_while_idle = false
      notification.data = {:registration_ids => ["#{gcm_device.registration_id}"], :data => {:message_text => message, :title_text => title, :notification_id => notification.id}}
      notification.save!
      notification.data = {:registration_ids => ["#{gcm_device.registration_id}"], :data => {:message_text => message, :title_text => title, :notification_id => notification.id}}
      notification.save!
      #puts notification.data
    end
    Gcm::Notification.send_notifications
  end
end

