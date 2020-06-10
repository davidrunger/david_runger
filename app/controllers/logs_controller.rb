# frozen_string_literal: true

class LogsController < ApplicationController
  include TokenAuthorizable

  def index
    user_id_param = params[:user_id]
    if user_id_param && params[:slug]
      sharing_user = User.find(user_id_param)
      shared_log = sharing_user.logs.find_by!(slug: params[:slug])
      authorize(shared_log, :show?)
      logs = Log.where(id: shared_log)
    else
      logs = current_user.logs.order(:created_at)

      slug = params[:slug]
      new_entry = params[:new_entry]
      if slug && new_entry
        verify_valid_auth_token!
        log = current_user.logs.find_by!(slug: slug)
        log.log_entries.create!(data: new_entry)
        bootstrap(toast_messages: ['New Log entry created!'])
      end
    end

    @title = 'Logs'
    @body_class = 'sans-serif'
    bootstrap(
      current_user: UserSerializer.new(current_user),
      logs: ActiveModel::Serializer::CollectionSerializer.new(
        logs.includes(:log_shares),
        scope: current_user,
        scope_name: :current_user,
      ),
      log_input_types: log_input_types,
    )
    render :index
  end

  private

  def log_input_types
    [
      { data_type: 'counter', label: 'Counter' },
      { data_type: 'duration', label: 'Duration' },
      { data_type: 'number', label: 'Number' },
      { data_type: 'text', label: 'Text' },
    ]
  end
end
