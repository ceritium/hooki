# frozen_string_literal: true

class Module
  # Marks the named method as intended to be redefined, if it exists.
  # Suppresses the Ruby method redefinition warning. Prefer
  # #redefine_method where possible.
  def silence_redefinition_of_method(method)
    return unless method_defined?(method) || private_method_defined?(method)

    # This suppresses the "method redefined" warning; the self-alias
    # looks odd, but means we don't need to generate a unique name
    alias_method method, method
  end

  # Replaces the existing method definition, if there is one, with the passed
  # block as its body.
  def redefine_method(method, &block)
    visibility = method_visibility(method)
    silence_redefinition_of_method(method)
    define_method(method, &block)
    send(visibility, method)
  end

  # Replaces the existing singleton method definition, if there is one, with
  # the passed block as its body.
  def redefine_singleton_method(method, &block)
    singleton_class.redefine_method(method, &block)
  end

  def method_visibility(method) # :nodoc:
    if private_method_defined?(method)
      :private
    elsif protected_method_defined?(method)
      :protected
    else
      :public
    end
  end
end
