module ApplicationHelper
  def formatted_date(date_or_time)
    date = date_or_time.is_a?(Date) ? date_or_time : date_or_time.try(:to_date)
    date.try(:strftime, '%m/%d/%Y')
  end
end
