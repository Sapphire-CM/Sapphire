class NotesController < ApplicationController
  def show 
    authorize Note
  end

  def create
    @note = @notable.notes.new(note_params)
    @note.account = current_account
    @note.term = @term

    authorize @note
    @note.save

    render partial: 'notes/render_list'
  end

  private
   
  def note_params
    params.require(:note).permit(:content)
  end
end
