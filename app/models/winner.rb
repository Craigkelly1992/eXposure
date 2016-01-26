class Winner < ActiveRecord::Base
  belongs_to :contest
  belongs_to :user
end
