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
    
    config.browser_validations = false

    # CSS class for buttons
    config.button_class = 'button'

    # CSS class to add for error notification helper.
    config.error_notification_class = 'alert-box alert'

    # The default wrapper to be used by the FormBuilder.
    config.default_wrapper = :foundation
  end
