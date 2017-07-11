module XMLSerializer
  class InitiationRequest

    def initialize(prior_authorization)
      @prior_authorization = prior_authorization
    end

    def serialize!
      init_request = NCPDP::InitiationRequest.new

      init_request.to = "EPIC_GENERIC_DXO"
      init_request.from = "DemoEHRApp"
      init_request.drug_attributes = DrugSerializer.new(nil).serialize!
      init_request.patient_attributes = PatientSerializer.new(@prior_authorization.patient).serialize!
      init_request.prescriber_attributes = PrescriberSerializer.new(@prior_authorization.prescriber).serialize!

      #TODO: when actual pas are being created change this to @prior_authorization.id
      init_request.pa_reference_id = SecureRandom.hex(10)

      init_request.relates_to_message_id = @prior_authorization.id

      init_request.to_xml
    end

  end
end
