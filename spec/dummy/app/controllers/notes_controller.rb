class NotesController < ApplicationController

  def index
    @notes = Note.scoped
  end

  def new
    @note = Note.new
  end

  def create
    @note = Note.new params[:note]
    if @note.save
      redirect_to notes_url
    else
      render 'new'
    end
  end

end
