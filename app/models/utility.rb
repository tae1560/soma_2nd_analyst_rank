class Utility
  def self.kor_str_to_utc_datetime str
    str.to_date.to_datetime - 9.hours
  end
  def self.utc_datetime_to_kor_str datetime
    datetime.in_time_zone("Seoul").to_date
  end
end