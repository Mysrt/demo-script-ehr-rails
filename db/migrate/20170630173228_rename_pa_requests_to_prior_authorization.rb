class RenamePaRequestsToPriorAuthorization < ActiveRecord::Migration
  def change
    rename_table :pa_requests, :prior_authorizations
  end
end
