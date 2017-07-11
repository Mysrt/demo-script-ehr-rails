class PrescriberSerializer

  def initialize(prescriber)
    @prescriber = prescriber
  end

  def serialize!
    {
      first_name: @prescriber.first_name,
      last_name: @prescriber.last_name,
      phone: @prescriber.practice_phone_number,
      npi: @prescriber.npi,
      fax: '6145555555',
        address_line1: @prescriber.practice_street_1,
        address_line2: @prescriber.practice_street_2,
        city: @prescriber.practice_city,
        state: @prescriber.practice_state,
        zip: @prescriber.practice_zip,
      country_code: 'US'
    }.deep_stringify_keys!
  end

  alias :to_hash :serialize!

end
