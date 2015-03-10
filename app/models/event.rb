class Event < ActiveRecord::Base
  belongs_to :subject, polymorphic: true
  belongs_to :issuer
end
