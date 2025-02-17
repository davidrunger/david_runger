class BlogController < ApplicationController
  class InvalidShowRequestFormat < StandardError ; end
  class UnauthorizedBlogFileRequest < StandardError ; end

  BLOG_DIRECTORY = Rails.root.join('blog').to_s.freeze
  SHOW_ACTION_PRESUMED_HTML_REQUEST_FORMATS = [nil, :html].freeze
  VALID_SHOW_ACTION_REQUEST_TYPES = [*SHOW_ACTION_PRESUMED_HTML_REQUEST_FORMATS, :xml].freeze

  all_actions = %i[assets index show]
  skip_before_action :authenticate_user!, only: all_actions
  before_action :skip_authorization, only: all_actions
  protect_from_forgery except: :assets

  def assets
    send_blog_file(request.path)
  end

  def index
    send_blog_file('/blog/index.html', disposition: 'inline')
  end

  def show
    # For feed requests, prioritize Atom/XML over other mime types.
    if xml_request_for_feed?
      request.format = :xml
    end

    request_format_symbol = request.format.symbol

    if request_format_symbol.in?(VALID_SHOW_ACTION_REQUEST_TYPES)
      file_path = request.path

      if (
        request_format_symbol.in?(SHOW_ACTION_PRESUMED_HTML_REQUEST_FORMATS) &&
          !file_path.end_with?('.html')
      )
        file_path << '.html'
      end

      send_blog_file(file_path, disposition: 'inline')
    else
      Rails.error.report(
        Error.new(InvalidShowRequestFormat),
        context: { request_format_symbol: },
      )

      head :not_found
    end
  end

  private

  def send_blog_file(relative_path, **kwargs)
    absolute_path =
      Rails.root.join(
        relative_path.to_s.sub(%r{\A/*}, ''),
      ).realpath.to_s

    if (
      absolute_path.start_with?(BLOG_DIRECTORY) &&
        absolute_path.match?(/\.(css|html|jpg|js|png|xml)\z/)
    )
      send_file(absolute_path, **kwargs)
    else
      Rails.error.report(
        Error.new(UnauthorizedBlogFileRequest),
        context: {
          absolute_path:,
          relative_path:,
        },
      )

      render_blog_404
    end
  rescue Errno::ENOENT
    Rails.error.report(
      Error.new(
        ActionController::RoutingError,
        %([blog] No route matches "#{request.fullpath}"),
      ),
      context: {
        relative_path:,
      },
    )

    render_blog_404
  end

  def render_blog_404
    send_file(Rails.root.join('blog/404.html'), status: 404, disposition: :inline)
  end

  def xml_request_for_feed?
    request.path == '/blog/feed.xml' &&
      Set.new(request.accepts).intersect?(Set.new([Mime[:atom], Mime[:xml]]))
  end
end
