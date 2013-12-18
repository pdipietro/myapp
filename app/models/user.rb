class User < Neo4j::Rails::Model
  attr_accessible :name, :email

  before_save { |user| user.email = email.downcase }

  property  :name, :type => String
  property  :email, :type => String, unique: true, index: :fulltext
  property  :password_digest, :type => String

  property  :created_at,  :type => DateTime
  property  :updated_at,  :type => DateTime

  validates :name,          presence: true

  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email,         presence: true,
                            format: { with: VALID_EMAIL_REGEX },
                            uniqueness: { case_sensitive: false }
  validates :password, presence: true, length: { minimum: 6 }
  validates :password_confirmation, presence: true


  # **********************************************************************************************************

  attr_reader :password

  validates_confirmation_of :password
  validates_presence_of     :password_digest

  # Returns self if the password is correct, otherwise false.
  def authenticate(unencrypted_password)
    if BCrypt::Password.new(password_digest) == unencrypted_password
      self
    else
      false
    end
  end

  # Encrypts the password into the password_digest attribute.
  def password=(unencrypted_password)
    @password = unencrypted_password
    unless unencrypted_password.blank?
      self.password_digest = BCrypt::Password.create(unencrypted_password)
    end
  end

  if respond_to?(:attributes_protected_by_default)
    def self.attributes_protected_by_default
      super + ['password_digest']
    end
  end

end


