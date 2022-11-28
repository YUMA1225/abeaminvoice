class Customer < ApplicationRecord
    belongs_to :user
    has_many :deals, dependent: :destroy
    validates :name, 
    presence: true
end
