class AddSendWelcomeNotificationsOptionToImportOptions < ActiveRecord::Migration[4.2]
  def change
    add_column :import_options, :send_welcome_notifications, :boolean, default: true
  end
end
