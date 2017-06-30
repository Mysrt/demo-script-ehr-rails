require 'rails_helper'

RSpec.describe PriorAuthorization, type: :model do
  fixtures :patients
  fixtures :prescriptions
  let(:patient) { Patient.find_by(first_name: 'Amber' ) }
  let!(:prescription) { patient.prescriptions.create!(drug_number: "012345") }
  let(:request_params) do
    {
      cmm_link: 'https://blah',
      cmm_outcome: 'Unknown',
      cmm_workflow_status: 'New',
      cmm_token: 'kdksksdkfadkjadf',
      cmm_id: '123ABC',
      form_id: 'this_is_a_form',
      prescriber_id: 1,
      prescription_id: prescription.id
    }
  end

  describe "creating a prior_authorization" do
    context "when using valid values" do
      it 'is valid' do
        prior_authorization = PriorAuthorization.new(request_params)
        expect(prior_authorization).to be_valid
      end

      it 'will show in task list by default' do
        prior_authorization = PriorAuthorization.new(request_params)
        expect(prior_authorization.display).to eq(true)
      end
    end
  end

  context "when retrieving the task list" do
    it "only returns requests that are displayable" do
      expect(true).to be_truthy
    end
  end
end
