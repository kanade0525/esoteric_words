module Admins
  class QuestionsController < ApplicationController
    before_action :set_question, only: [:edit, :update, :destroy]

    def index
      @questions = Question.all
    end

    def new
      @question = Question.new
    end

    def create
      @question = Question.new(question_params)
      if @question.save
        redirect_to admins_questions_path, notice: '難解な単語が作成されました。'
      else
        render :new
      end
    end

    def edit
    end

    def update
      if @question.update(question_params)
        redirect_to admins_questions_path, notice: '難解な単語が更新されました。'
      else
        render :edit
      end
    end

    def destroy
      @question.destroy
      redirect_to admins_questions_path, notice: '難解な単語が削除されました。'
    end

    private

    def set_question
      @question = Question.find(params[:id])
    end

    def question_params
      params.require(:question).permit(:content)
    end
  end
end 
