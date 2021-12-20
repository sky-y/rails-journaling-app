class NotesController < ApplicationController
  def new
    @odai = Subject.choose_one.odai
  end
end
