module SimpleForm
  module Inputs
    class DatePickerInput < StringInput
      def input(wrapper_options)
        value = object.send(attribute_name) if object.respond_to? attribute_name
        input_html_options[:value] ||= value.strftime("%Y-%m-%d") if value.present?

        input_html_options[:type] = 'text'
        input_html_options[:data] ||= {}
        input_html_options[:data].merge!({ 'date-format' => 'yyyy-mm-dd' })

        template.content_tag :div, class: 'input-append date', data: { behavior: 'date-picker'} do
          template.content_tag :div, class: 'row collapse' do
            input = ""
            input += template.content_tag :div, class: 'small-1 columns' do
              template.content_tag :a, class: 'prefix secondary button' do
                template.content_tag :i, "", class: 'fi-calendar'
              end
            end
            input+= template.content_tag :div, class: 'small-11 columns' do
               super # leave StringInput do the real rendering
             end
            input.html_safe
          end
        end
      end
    end
  end
end

module SimpleForm
  module Inputs
    class DatetimePickerInput < StringInput
      def input(wrapper_options)
        value = object.send(attribute_name) if object.respond_to? attribute_name
        input_html_options[:value] ||= value.strftime("%Y-%m-%d %H:%M") if value.present?

        input_html_options[:type] = 'text'
        input_html_options[:data] ||= {}
        input_html_options[:data].merge!({ 'date-format' => 'yyyy-mm-dd hh:ii' })

        template.content_tag :div, class: 'input-append date', data: { behavior: 'datetime-picker'} do
          template.content_tag :div, class: 'row collapse' do
            input = ""
            input += template.content_tag :div, class: 'small-1 columns' do
              template.content_tag :a, class: 'prefix secondary button' do
                template.content_tag :i, "", class: 'fi-calendar'
              end
            end
            input+= template.content_tag :div, class: 'small-11 columns' do
               super # leave StringInput do the real rendering
             end
            input.html_safe
          end
        end
      end
    end
  end
end


SimpleForm.setup do |config|
  config.wrappers :foundation, class: :input, error_class: :error do |b|
    b.use :html5
    b.use :placeholder
    b.optional :maxlength
    b.optional :pattern
    b.optional :min_max
    b.optional :readonly
    b.use :label_input
    b.use :error, wrap_with: { tag: :small }
  end

  config.default_wrapper = :foundation
  config.boolean_style = :nested
  config.browser_validations = false
  config.button_class = 'button'
  config.error_notification_class = 'alert-box alert'
end

