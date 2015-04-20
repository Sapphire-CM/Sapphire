class AddSendWelcomeNotificationsOptionToImportOptions < ActiveRecord::Migration
  def change
    add_column :import_options, :send_welcome_notifications, :boolean, default: true
  end
end
