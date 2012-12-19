module LayoutHelper
  def title(title, show_title = true)
    content_for :title, title
    @show_title = show_title
  end
end
