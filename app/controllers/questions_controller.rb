class QuestionsController < ApplicationController
  def index
    @questions = Question.all.sort_by(&:id)
  end
end
