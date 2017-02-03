module ApplicationHelper
  def base_href
    Rails.env.in?(['development', 'test']) ? "/" :"/"
  end
end
