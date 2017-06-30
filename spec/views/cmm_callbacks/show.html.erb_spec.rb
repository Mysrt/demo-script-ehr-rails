require 'rails_helper'

RSpec.describe "cmm_callbacks/show", :type => :view do
  fixtures(:patients)
  before(:each) do
    @prescription = Prescription.create!(patient: Patient.first, drug_number: "12345")
    @pa = PriorAuthorization.create!(cmm_id:'1234', prescription: @prescription)
    @callback = assign(:callback, CmmCallback.create!(
                         :content => "{\"MyText\":\"hello\"}",
                         prior_authorization: @pa
    ))
  end

  it "renders attributes in <code>" do
    render
    expect(rendered).to match(/MyText/)
  end
end
