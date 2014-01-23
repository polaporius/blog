require 'sinatra/base'

module Posting
  def title
    if @title
      "#{@title} -- My Blog"
    else
      "My Blog"
    end
  end

  def pretty_date(time)
    time.strftime("%d %b %Y")
  end

  def post_show_page?
    request.path_info =~ /\/posts\/\d+$/
  end

  def delete_post_button(post_id)
    if author? @post
      erb :"partial/_delete_post_button", locals: { post_id: post_id }
    end
  end

  def delete_comment_button(comment_id)
    if author? @post
      erb :"partial/_delete_comment_button", locals: { comment_id: comment_id}
    end
  end

  def author? post
    post.user == User.find_by(email: session[:all].email)
  end

  def h(text)
    Rack::Utils.escape_html(text)
  end
end 