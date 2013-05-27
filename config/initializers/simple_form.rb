module SimpleForm
  module Inputs
    class DatePickerInput < StringInput
      def input
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
                template.content_tag :i, "", class: 'general foundicon-calendar'
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
      def input
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
                template.content_tag :i, "", class: 'general foundicon-calendar'
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


# Use this setup block to configure all options available in SimpleForm.
SimpleForm.setup do |config|
  # Wrappers are used by the form builder to generate a
  # complete input. You can remove any component from the
  # wrapper, change the order or even add your own to the
  # stack. The options given below are used to wrap the
  # whole input.
  config.wrappers :foundation, class: :input, hint_class: :field_with_hint, error_class: :error do |b|
    b.use :html5
    b.use :placeholder
    b.optional :maxlength
    b.optional :pattern
    b.optional :min_max
    b.optional :readonly
    b.use :label_input
    b.use :error, wrap_with: { tag: :small }

    # Uncomment the following line to enable hints. The line is commented out by default since Foundation
    # does't provide styles for hints. You will need to provide your own CSS styles for hints.
    # b.use :hint,  wrap_with: { tag: :span, class: :hint }
  end

  # HTML input-checkbox nested inside label
  config.boolean_style = :nested
  
  
  config.browser_validations = false
  
  # CSS class for buttons
  config.button_class = 'button'

  # CSS class to add for error notification helper.
  config.error_notification_class = 'alert-box alert'

  # The default wrapper to be used by the FormBuilder.
  config.default_wrapper = :foundation
end

