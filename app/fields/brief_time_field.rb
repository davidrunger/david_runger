# frozen_string_literal: true

require 'administrate/field/base'

class BriefTimeField < Administrate::Field::Base
  def to_s
    data.strftime('%b %-d %l:%M%P').squish
  end
end
