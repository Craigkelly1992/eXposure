class Agency < ActiveRecord::Base
  self.per_page = 18
  attr_accessor :terms
  has_many :brands, dependent: :destroy
  has_many :contests, through: :brands
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :phone, presence: true
  validates :company_name, presence: true

  def owns?(resource)
    if resource.class.name.downcase == "contest"
      self.contests.find(resource.id)
    elsif resource.class.name.downcase == "brand"
      self.brands.find(resource.id)
    end
  end

  def full_name
    "#{self.first_name} #{self.last_name}"
  end

  def self.current
    Thread.current[:agency]
  end
  def self.current=(agency)
    Thread.current[:agency] = agency
  end

end
