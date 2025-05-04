class QuestionsController < ApplicationController
  def index
    @questions = Question.order(:id)
  end
end
