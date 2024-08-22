class Api::ReificationsController < Api::BaseController
  def create
    @version = PaperTrail::Version.find(params[:paper_trail_version_id])

    authorize(@version, :create?, policy_class: ReificationsPolicy)

    @version.reify.save!

    head :ok
  end
end
