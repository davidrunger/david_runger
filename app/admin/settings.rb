# frozen_string_literal: true

# much of this is borrowed from https://stackoverflow.com/a/24958513/4009384
ActiveAdmin.register_page('Settings') do
  menu parent: 'Admin'

  action_item :edit, only: :show do
    setting_name = params[:name]
    link_to('Edit Setting', admin_settings_edit_path(name: setting_name))
  end

  action_item :destroy, only: :show do
    setting_name = params[:name]
    link_to('Delete Setting', admin_settings_destroy_path(name: setting_name), method: :delete)
  end

  action_item :new do
    link_to 'New Setting', admin_settings_new_path
  end

  page_action :index do
    @page_title = 'Settings'
    settings = RedisConfig.all
    render :index, layout: 'active_admin', locals: { settings: settings }
  end

  page_action :show do
    setting_name = params[:name]
    @page_title = setting_name
    setting = RedisConfig.get(setting_name)
    render :show, layout: 'active_admin', locals: { setting: setting }
  end

  page_action :new do
    @page_title = 'New Setting'
    @setting =
      RedisConfig::SettingDecorator.new(
        RedisConfig::Setting.new(name: nil, type: nil, value: nil),
      )
    render :form, layout: 'active_admin'
  end

  page_action :edit do
    setting_name = params[:name]
    @page_title = %(Edit "#{setting_name}" Setting)
    @setting =
      RedisConfig::SettingDecorator.new(
        RedisConfig.get(setting_name),
      )
    render :form, layout: 'active_admin'
  end

  page_action :create, method: :post do
    setting_params = params.require(:redis_config_setting)
    setting_name = setting_params[:name]
    RedisConfig.add(*setting_params.permit(:name, :type).to_h.values)
    if (value = setting_params[:value].presence)
      RedisConfig.set(setting_name, value)
    end
    flash[:notice] = %(Setting "#{setting_name}" created.)
    redirect_to admin_settings_show_path(name: setting_name)
  end

  page_action :update, method: :patch do
    setting_params = params.require(:redis_config_setting)
    setting_name = setting_params[:name]
    value = setting_params[:value].presence
    RedisConfig.set(setting_name, value)
    flash[:notice] = 'Setting updated.'
    redirect_to admin_settings_show_path(name: setting_name)
  end

  page_action :destroy, method: :delete do
    setting_name = params[:name]
    RedisConfig.delete(setting_name)
    flash[:notice] = 'Setting deleted.'
    redirect_to admin_settings_path(name: setting_name)
  end
end
