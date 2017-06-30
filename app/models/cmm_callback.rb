class CmmCallback < ActiveRecord::Base
  belongs_to :prior_authorization, inverse_of: :cmm_callbacks
end
