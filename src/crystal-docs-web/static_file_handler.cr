require "ecr/macros"
require "html"
require "uri"
require "http"

# Bastardised copy of the original Crystal StaticFileHandler implementation.
# This version will load a file by the name of index.html if it's present in a directory and it will not show a
# directory listing, it will instead return a 404.
class StaticFileHandler < HTTP::Handler
  @public_dir : String

  # Creates a handler that will serve files in the given *public_dir*, after
  # expanding it (using `File#expand_path`).
  #
  # If *fallthrough* is `false`, this handler does not call next handler when
  # request method is neither GET or HEAD, then serves `405 Method Not Allowed`.
  # Otherwise, it calls next handler.
  def initialize(public_dir : String, fallthrough = true)
    @public_dir = File.expand_path public_dir
    @fallthrough = !!fallthrough
  end

  def call(context)
    unless context.request.method == "GET" || context.request.method == "HEAD"
      if @fallthrough
        call_next(context)
      else
        context.response.status_code = 405
        context.response.headers.add("Allow", "GET, HEAD")
      end
      return
    end

    original_path = context.request.path.not_nil!
    is_dir_path = original_path.ends_with? "/"
    request_path = URI.unescape(original_path)

    # File path cannot contains '\0' (NUL) because all filesystem I know
    # don't accept '\0' character as file name.
    if request_path.includes? '\0'
      context.response.status_code = 400
      return
    end

    expanded_path = File.expand_path(request_path, "/")
    if is_dir_path && !expanded_path.ends_with? "/"
      expanded_path = "#{expanded_path}/"
    end
    is_dir_path = expanded_path.ends_with? "/"

    file_path = File.join(@public_dir, expanded_path)
    is_dir = Dir.exists? file_path

    if request_path != expanded_path || is_dir && !is_dir_path
      redirect_to context, "#{expanded_path}#{is_dir && !is_dir_path ? "/" : ""}"
      return
    end

    is_root_path = file_path.gsub("/var/www/", "").empty?

    if Dir.exists?(file_path) && !is_root_path
      index_path = "#{file_path}index.html"
      if File.exists?(index_path)
        context.response.content_type = "text/html"
        context.response.content_length = File.size(index_path)
        File.open(index_path) do |file|
          IO.copy(file, context.response)
        end
      else
        call_next(context)
      end
      # directory_listing(context.response, request_path, file_path)
    elsif File.exists?(file_path) && !is_dir
      context.response.content_type = mime_type(file_path)
      context.response.content_length = File.size(file_path)
      File.open(file_path) do |file|
        IO.copy(file, context.response)
      end
    else
      call_next(context)
    end
  end

  private def redirect_to(context, url)
    context.response.status_code = 302

    url = URI.escape(url) { |b| URI.unreserved?(b) || b != '/' }
    context.response.headers.add "Location", url
  end

  private def mime_type(path)
    case File.extname(path)
    when ".txt"          then "text/plain"
    when ".htm", ".html" then "text/html"
    when ".css"          then "text/css"
    when ".js"           then "application/javascript"
    else                      "application/octet-stream"
    end
  end
end
