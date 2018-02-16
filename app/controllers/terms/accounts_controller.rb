class Terms::AccountsController < ApplicationController
  include TermContext

  def index
    authorize Terms::AccountPolicy.term_policy_record(@term)

    @accounts = Account.search(params[:q])

    respond_to do |format|
      format.json
    end
  end
end
