class Deal < ApplicationRecord
    belongs_to :customer

    validates :title,
    presence: true
    validates :price,
    presence: true,
    numericality: true

    validates :amount,
    presence: true,
    numericality: true

end
