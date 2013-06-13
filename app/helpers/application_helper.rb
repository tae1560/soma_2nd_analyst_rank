#coding:utf-8
module ApplicationHelper

  def display_base_errors resource
    return '' if (resource.errors.empty?) or (resource.errors[:base].empty?)
    messages = resource.errors[:base].map { |msg| content_tag(:p, msg) }.join
    html = <<-HTML
    <div class="alert alert-error alert-block">
      <button type="button" class="close" data-dismiss="alert">&#215;</button>
      #{messages}
    </div>
    HTML
    html.html_safe
  end

  def mobile_device?
    if session[:mobile_param]
      session[:mobile_param] == "1"
    else
      result = request.user_agent =~ /Mobile|webOS/
      result != nil
    end
  end

  def display_recent_period_string recent_period=nil
    unless recent_period
      recent_period = @recent_period
    end

    if recent_period.name == "전체"
      html = <<-HTML
        <span class="param">#{recent_period.name}</span> 추천을
      HTML
    else
      html = <<-HTML
      최근 <span class="param">#{recent_period.name}</span> 추천을
      HTML
    end

    html.html_safe
  end

  def display_keep_period_string keep_period=nil
    unless keep_period
      keep_period = @keep_period
    end

    html = <<-HTML
        <span class="param">#{keep_period.name}</span> 동안 유지할 때
    HTML

    html.html_safe
  end
  def display_loss_cut_string loss_cut=nil
    unless loss_cut
      loss_cut = @loss_cut
    end

    if loss_cut.percent < 0
      html = <<-HTML
      손절매 <span class="param">X</span>
      HTML
    else
      html = <<-HTML
      손절매 <span class="param">#{loss_cut.percent}%</span>
      HTML
    end

    html.html_safe
  end

end
