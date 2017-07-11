class PatientSerializer

  def initialize(patient)
    @patient = patient
  end

  def serialize!
    {
      country_code: 'US',
      address_line1: @patient.street_1,
      address_line2: @patient.street_2,
      city: @patient.city,
      state: @patient.state,
      zip: @patient.zip, 
      date_of_birth: @patient.date_of_birth,
      gender: @patient.gender,
      first_name: @patient.first_name,
      last_name: @patient.last_name,
      phone: @patient.phone_number,
      communcation_numbers: {
        primary_telephone: { number: "6145555555" },
        fax: { number: "0000000000" },
      },
      member_number: @patient.id,
    }.deep_stringify_keys!
  end

  alias :to_hash :serialize!

end
