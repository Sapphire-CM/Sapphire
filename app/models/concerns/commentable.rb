module Commentable
  extend ActiveSupport::Concern

  class_methods do
    def has_many_comments(name)
      has_many "#{name}_comments".to_sym, lambda { where(name: name) }, as: :commentable, class_name: "Comment", dependent: :destroy

      scope "with_#{name}_comments", lambda { includes("#{name}_comments") }
    end
  end
end
