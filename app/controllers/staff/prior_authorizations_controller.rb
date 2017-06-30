module Staff
  class PriorAuthorizationsController < ApplicationController
    before_action :set_patient, only: [:create]

    def new
      @prior_authorization = PriorAuthorization.new 
      @prescription = Prescription.new
    end

    def create
      @prescription = @patient.prescriptions.create!(
        prescription_params.merge({
          date_prescribed: DateTime.now,
          pa_required: true,
          }))

      @prior_authorization = @prescription.prior_authorizations.build(prior_authorization_params)

      response = CoverMyMeds.default_client.create_request  RequestConfigurator.new(@prior_authorization).request
      flash_message "Your prior authorization request was successfully started."

      @prior_authorization.set_cmm_values(response)

      respond_to do |format|
        if @prior_authorization.save
          format.html { redirect_to @patient }
        else
          format.html { render :new }
        end
      end
    end

    def show
      @prior_authorization = PriorAuthorization.find(params[:id])
    end

    private

    def patient_params
      params.require(:patient)
    end

    def set_patient
      @patient = Patient.find(patient_params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def prior_authorization_params
      params.require(:prior_authorization)
            .permit(:prescriber_id,
                    :form_id, 
                    :urgent, 
                    :state)
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def prescription_params
      params.require(:prescription)
            .permit(:drug_number, 
                    :drug_name,
                    :quantity, 
                    :frequency, 
                    :refills, 
                    :dispense_as_written)
    end
  end
end
