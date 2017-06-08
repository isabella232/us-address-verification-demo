class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  validate :address_verification

  private

  def address_verification
    lob = Lob::Client.new(api_key: ENV["lob_api_key"])

    address = lob.us_verifications.verify(
      primary_line: self.address_line1,
      secondary_line: self.address_line2,
      city: self.address_city,
      state: self.address_state,
      zip_code: self.address_zip,
    )

    if address["deliverability"] != "deliverable"
      errors.add("This address is not deliverable: ", address["deliverability"])
    end

  end
end
