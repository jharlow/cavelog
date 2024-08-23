class NotInFutureValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    if value.present? && value > Time.current
      record.errors.add(attribute, "can't be in the future")
    end
  end
end
