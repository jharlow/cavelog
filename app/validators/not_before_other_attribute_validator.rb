class NotBeforeOtherAttributeValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    other_attribute = options[:with]
    other_value = record.send(other_attribute)

    if value.present? && other_value.present? && value < other_value
      record.errors.add(attribute, :not_before_other, message: options[:message] || "cannot be before #{other_attribute.to_s.humanize.downcase}")
    end
  end
end
