class PriorAuthorization < ActiveRecord::Base
  include Sidekiq::Worker

  belongs_to :prescription
  belongs_to :prescriber, class_name: 'User'
  belongs_to :user, inverse_of: :prior_authorizations, foreign_key: :prescriber_id

  has_one :patient, through: :prescription
  has_many :cmm_callbacks, inverse_of: :prior_authorization

  validates_presence_of :prescription

  default_scope { where(display: true).order(updated_at: :desc) }

  scope :archived, -> () { where(cmm_workflow_status: 'Archived') }
  scope :need_input,  -> () { where("(cmm_workflow_status = 'New' OR cmm_workflow_status = 'Shared' OR cmm_workflow_status ilike '%response%') and cmm_outcome is null") }
  scope :awaiting_response, -> () { where("cmm_workflow_status ilike '%request%' OR cmm_workflow_status ilike '%sent%'") }
  scope :determined, -> () { where("cmm_workflow_status ilike 'Expired' or (cmm_outcome is not null and cmm_workflow_status not ilike 'Archived')") }

  OUTCOME_MAP = {
    unfavorable:  'Denied',
    favorable:    'Approved',
    na:           'Not Needed',
    unsent:       'Unsent',
    cancelled:    'Cancelled',
    unknown:      'Unknown'
  }.freeze

  STATUS_MAP = {
    question_request:     'Request',
    question_response:    'Response',
    prior_authorization:  'Request',
    pa_response:          'Response',
    appeal_request:       'Request',
    appeal_response:      'Response',
    cancel_request_sent:  'Request',
    provider_cancel:      'Response',
    sent_to_plan:         'Request',
    archived:             'Response'
  }.freeze


  def perform
    xml = XMLSerializer::InitiationRequest.new(self).serialize!

    NcpdpEHRService.new.post(xml)
  end

  def last_updated
    updated_at.in_time_zone(Time.zone.name)
  end

  def outcome
    outcome = cmm_outcome.downcase.parameterize.underscore.to_sym
    OUTCOME_MAP[outcome] || cmm_outcome
  end

  def status
    status = cmm_workflow_status.downcase.parameterize.underscore.to_sym
    STATUS_MAP[status] || cmm_workflow_status
  end

  def set_cmm_values(response)
    self.cmm_link = response.tokens[0].html_url
    self.cmm_id = response.id
    self.cmm_workflow_status = response.workflow_status || 'Not Yet Started'
    self.cmm_outcome = response.plan_outcome || 'Undetermined'
    self.cmm_token = response.tokens[0].id
    self.form_id = response.form_id
    self.state = response.state
    self
  end

  def cmm_workflow_status
    read_attribute(:cmm_workflow_status) || 'Not Started'
  end

  def cmm_outcome
    read_attribute(:cmm_outcome) || "Unknown"
  end

  def init_from_callback(cb_data, options = {})
    self.cmm_id = cb_data['id']
    self.cmm_workflow_status = cb_data['workflow_status']
    self.cmm_outcome = cb_data['plan_outcome']
    self.cmm_token = cb_data['tokens'][0]['id']
    self.cmm_link = cb_data['tokens'][0]['html_url']
    self.form_id = cb_data['form_id']
    self.urgent = cb_data['urgent']
    self.state = cb_data['state']
    self.is_retrospective = options[:retro].present?

    # look up the patient & prescription, if they exist
    patient_info = cb_data['patient']
    patient = Patient.where(
      first_name: patient_info['first_name'],
      last_name: patient_info['last_name']).first

    payer_info = cb_data['payer']

    patient ||= Patient.create_from_callback(patient_info, payer_info)

    prescription_data = cb_data['prescription']
    prescription = patient.prescriptions.where(
      drug_number:prescription_data['drug_id']).order(date_prescribed: :desc).first

    if prescription.nil?
      prescription = Prescription.create!({
        drug_number: cb_data['prescription']['drug_id'],
        drug_name: cb_data['prescription']['name'],
        quantity: cb_data['prescription']['quantity'],
        frequency: cb_data['prescription']['frequency'],
        dispense_as_written: false,
        patient: patient
        })
    end

    self.prescription = prescription
  end

  def remove_from_dashboard
    CoverMyMeds.default_client.revoke_access_token?(cmm_token)
    update_attributes(display: false)
  end

  def self.for_status(status)
    case status.to_sym
    when :need_input
      PriorAuthorization.need_input
    when :awaiting_response
      PriorAuthorization.awaiting_response
    when :determined
      PriorAuthorization.determined
    when :archived
      PriorAuthorization.archived
    when :all
      PriorAuthorization.all
    else
      PriorAuthorization.need_input
    end
  end


end
