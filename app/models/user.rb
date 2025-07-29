class User < ApplicationRecord

    has_secure_password

    has_many :subjects, dependent: :destroy 
    has_many :paragraphs, dependent: :destroy
    has_many :questions, through: :paragraphs

    has_many :collaborations, dependent: :destroy
    has_many :collaborated_subjects, through: :collaborations, source: :subject
    
    validates :username, presence: true, uniqueness: true
    validates :email, presence: true, uniqueness: true , format: { with: URI::MailTo::EMAIL_REGEXP, message: "Please Enter Valid Email Address" }
    validates :password, presence: true, length: {minimum: 5}


    private

    def passwords_mismatch
        errors.add(:passwords_confirmation, "passwords do not match!!") if password != password_confirmation
    end
end