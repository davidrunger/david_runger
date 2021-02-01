# frozen_string_literal: true

def populate_banned_path_fragments
  %w[
    administrator
    env
    git
    passwd
    php
    phpformbuilder
    phpmyadmin
    phpmyadmin
    phpunit
    plugins
    wordpress
    wp
    wp1
    wp2
  ].each do |path_fragment_string|
    BannedPathFragment.create!(value: path_fragment_string)
  end
end
