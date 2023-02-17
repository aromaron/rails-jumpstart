class TailwindFormBuilder < ActionView::Helpers::FormBuilder
  # include ActionView::Helpers::TagHelper
  # include ActionView::Context

  def label(method, text = nil, options = {}, &block)
    @template.label(@object_name, method, text, objectify_options(options.reverse_merge(class: "label")), &block)
  end

  def text_field(object_name, options = {})
    super(object_name, options.reverse_merge(class: "input"))
  end

  def email_field(object_name, options = {})
    super(object_name, options.reverse_merge(class: "input"))
  end

  def password_field(attribute, options = {})
    super(attribute, options.reverse_merge(class: "input"))
  end

  def text_area(attribute, options = {})
    super(attribute, options.reverse_merge(class: "input"))
  end

  def select(object_name, method_name, template_object, options = {})
    super(object_name, method_name, template_object, options.reverse_merge(class: "select"))
  end

  def submit(value = nil, options = {})
    value, options = nil, value if value.is_a?(Hash)
    value ||= submit_default_value
    @template.submit_tag(value, options.reverse_merge(class: "button"))
  end

  def button(value = nil, options = {}, &block)
    case value
    when Hash
      value, options = nil, value
    when Symbol
      value, options = nil, {name: field_name(value), id: field_id(value)}.merge!(options.to_h)
    end
    value ||= submit_default_value

    if block
      value = @template.capture { yield(value) }
    end

    formmethod = options[:formmethod]
    if formmethod.present? && !/post|get/i.match?(formmethod) && !options.key?(:name) && !options.key?(:value)
      options.merge! formmethod: :post, name: "_method", value: formmethod
    end

    @template.button_tag(value, options.reverse_merge(class: "button"))
  end

  def div_radio_button(method, tag_value, options = {})
    @template.content_tag(:div,
      @template.radio_button(
        @object_name, method, tag_value, objectify_options(options)
      ))
  end
end
