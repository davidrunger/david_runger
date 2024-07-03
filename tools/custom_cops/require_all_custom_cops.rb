# frozen_string_literal: true

Dir[File.expand_path('./**/*.rb', __dir__)].each do |file|
  unless file == __FILE__
    require file
  end
end
