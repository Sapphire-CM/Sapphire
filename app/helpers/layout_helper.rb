module LayoutHelper
  def title(title, subtitle = nil, options = {})
    content_for :title, title
    @show_title = true

    @small_title = !!options[:small]

    if subtitle.is_a? String
      content_for :subtitle, subtitle
    elsif subtitle.is_a? FalseClass
      @show_title = false
    end
  end

  def large_content(enabled)
    content_for :large_content, 'large-full' if enabled
  end

  def link_to_current_term
    if term_context?
      link_to course_term_title, term_path(@term)
    else
      # Todo: change to not using a link here!
      link_to '<em>-- no term selected --</em>'.html_safe, '#'
    end
  end

  def sidebar(text = '', &block)
    if block_given?
      content_for :sidebar, capture(&block)
    else
      content_for :sidebar, text
    end
  end

  def sidebar_nav(&block)
    content_for :sidebar, content_tag(:ul, capture(&block), class: 'side-nav')
  end

  def sidenav_item(icon, title, path, active = nil)
    options = {}
    options[:class] = 'active' if (active.nil? && request.fullpath == path) || (!active.nil? && active)

    content_tag(:li, link_to("#{foundation_icon icon} #{h title}".html_safe, path), options)
  end

  def subnav_item(icon, title, path, active)
    options = {}
    options[:class] = 'active' if active
    content_tag(:dd, link_to("#{foundation_icon icon} #{h title}".html_safe, path), options)
  end

  def flash_class_for(key)
    classes = ['alert-box']

    if key == 'notice'
      classes << 'success'
    elsif key == 'error' || key == 'alert'
      classes << 'alert'
    elsif key == 'secondary'
      classes << 'secondary'
    end

    classes.join(' ')
  end

  def course_term_title(term = nil)
    term ||= if respond_to?(:current_term)
      current_term
    else
      @term
    end

    "#{term.course.title}: #{term.title}" if term
  end

  # Todo: scope this appropriatly for the current_user
  def navigation_context_selector
    terms = Term
    terms = terms.where { id != my { current_term.id } } if term_context?

    render 'application/navigation_context_selector', terms: terms.all
  end

  def shorten(text, length)
    short = truncate(text, length: length)

    short = content_tag(:span, short, title: text, class: 'has-tip', data: { tooltip: '' }).html_safe if short != text

    short
  end

  def side_navigation_item(title, path, options = {})
    classes = []

    if options[:active].nil?
      classes << 'active' if current_page?(path)
    else
      classes << 'active' if options[:active]
      options = options.except(:active)
    end

    content_tag :li, link_to(title, path, options), class: classes.join(' ')
  end

  def rating_group_full_title(rating_group)
    full_title = rating_group.title
    full_title += ": #{rating_group_subtitle_points(rating_group)}" unless rating_group.global

    full_title
  end

  def rating_group_subtitle_points(rating_group)
    subtitle = "#{pluralize rating_group.points, 'point'}"
    subtitle += " (#{rating_group.min_points} ... #{rating_group.max_points})" if rating_group.enable_range_points

    subtitle
  end

  def highlight_search(haystack, needle)
    if haystack.present? && needle.present?
      highlight(haystack, needle.split(/\s+/))
    else
      haystack
    end
  end

  def foundation_icon(icon)
    "<i class='fi-#{icon.to_s.dasherize}'></i>".html_safe
  end

  def dropdown_button(title, links, options = {})
    dropdown_identifier = "dropdown-button-#{SecureRandom.hex}"

    dropdown_classes = ['f-dropdown']
    dropdown_classes << options[:dropdown_class] if options[:dropdown_class]

    render 'dropdown_button', title: title, dropdown_identifier: dropdown_identifier, links: links, dropdown_classes: dropdown_classes.join(' ')
  end
end
