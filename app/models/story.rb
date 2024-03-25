# frozen_string_literal: true

class Story < ApplicationRecord
  enum type: {
    'Story::PostStory' => 1,
    follow: 2,
    media_reaction: 3
  }
end
