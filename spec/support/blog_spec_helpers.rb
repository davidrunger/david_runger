module BlogSpecHelpers
  def with_blog_file(path, content)
    file_path = Rails.root.join('blog', path)
    FileUtils.mkdir_p(file_path.dirname)
    File.write(file_path, content)

    yield

    FileUtils.rm(file_path)
  end
end
