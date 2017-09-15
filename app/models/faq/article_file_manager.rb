module FAQ
  class ArticleFileManager
    RESPONSE_TYPE = 4

    include FilePath

    def export
      CSV.open( faq_article_file, 'wt' ) do | csv |
        Question.each do | question |
          response = { ResponseValue:response_value_for( question ),
                       ResponseType:RESPONSE_TYPE }
          response_json = JSON.generate( response, space:' ' )

          csv << [ question.text, response_json ]
        end
      end
    end


    private

    def response_value_for question
      answers_ary = question
                      .article
                      .answers.map do | a |
                        { Answers:answers_for( a )}
                    end

      { isFaq:question.is_faq.to_s.upcase,
        Answers:answers_ary,
        id: question.article.kbid }
    end

    def answers_for answer
      { outputMetaData:answer.metadata,
        isDefault:answer.active.to_s.upcase,
        Answer:answer.text }
    end
  end
end
