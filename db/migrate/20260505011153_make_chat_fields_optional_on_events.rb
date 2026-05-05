class MakeChatFieldsOptionalOnEvents < ActiveRecord::Migration[8.1]
  def change
    change_column_null :events, :chat_platform, true
    change_column_null :events, :chat_url, true
  end
end
