module ApplicationHelper
  def formatted_date(date_or_time)
    date = date_or_time.is_a?(Date) ? date_or_time : date_or_time.try(:to_date)
    date.try(:strftime, '%m/%d/%Y')
  end

  def formatted_time(time)
    begin
      if time.is_a?(String)
        time = Time.parse time
      end
      if time
       time.in_time_zone("Eastern Time (US & Canada)").strftime( '%d %b, %Y %I:%M %p') + " EST"
      else
        ''
      end
    rescue
      "Invalid Time"
    end
  end

  def formatted_changeset(hash, searched_attribute=nil)
    #hash format key => [old_value, new_value]
    data_rows = ''
    unless hash.empty?
      data_rows = hash.collect do |key, value|
        if key =~ /_at$/
          value = value.collect do |v|
            formatted_time v
          end
        end
        "<tr><td>#{key}</td><td>#{value.first}</td><td>#{value.last}</td></tr>" if searched_attribute && searched_attribute == key
      end
      data_rows = data_rows.join('')
    end
    "<table><tr><th>Field</th><th>Previous Value</th><th>New Value</th></tr>#{data_rows}</table>"
  end

  def whodunnit_user(whodunnit)
    if whodunnit == 'Unknown User'
      return whodunnit
    elsif whodunnit.nil?
      return 'Unknown User'
    else
      user =  User.find_by_id(whodunnit)
      if user
        return link_to user.name, admin_user_path(user)
      else
        'Unknown User'
      end
    end
  end
end


# Ability to query change on a single attribute of an object and see parsed results of what changed on that attribtues
