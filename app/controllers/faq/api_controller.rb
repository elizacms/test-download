module FAQ
  class APIController < ApplicationController
    PAGE_LIMIT = 10

    skip_before_action :verify_authenticity_token

    def search
      case params[:search_type]
      when 'kbid'
        results = Article.includes( :answers, :questions )
                         .where(kbid: params[:input_text])
                         .map { |a| format_one a }
      when 'query'
        results = Question.includes( :article )
                          .full_text_search(params[:input_text])
                          .offset( offset    )
                          .limit( PAGE_LIMIT )
                          .map{|a| format_one( a.article ) }
                          .uniq
      when 'response'
        results = Answer.includes( :article )
                        .full_text_search(params[:input_text])
                        .offset( offset    )
                        .limit( PAGE_LIMIT )
                        .map{|q| format_one( q.article ) }
                        .uniq
      end

      pages = results.count / PAGE_LIMIT + 1
      body = { total:   results.count,
               pages:   pages,
               results: results }

      render json:body.to_json
    end

    def get_articles
      total = Article.count
      pages = total / PAGE_LIMIT + 1

      body = { total:   total    ,
               pages:   pages    ,
               results: articles }

      render json:body.to_json
    end

    def post_articles
      if article_params[:kbid]
        headers['Warning'] = 'Cannot POST for an existing article.'\
                             ' Call PUT to "/api/articles/:kbid".'
        render body:{}.to_json, status: 422
        return
      end

      article = Article.create(enabled: article_params[:enabled])
      save_associations article, article_params[:questions], article_params[:answers]

      render body:{}.to_json, status: 201
    end

    def put_articles
      article = Article.find_by(kbid: article_params[:kbid])

      unless article
        headers['Warning'] = 'No article found. You must send an existing kbid.'
        render body:{}.to_json, status: 404
        return
      end

      delete_associations article
      save_associations article, article_params[:questions], article_params[:answers]
      article.update( enabled: article_params[ :enabled ] )

      render body:{}.to_json, status: 200
    end

    def delete_articles
      article = Article.find_by(kbid: article_params[:kbid])

      if article
        delete_associations article
        article.delete

        render body:{}.to_json, status: 200
      else
        headers['Warning'] = 'No article found. You must send an existing kbid.'
        render body:{}.to_json, status: 404
      end
    end


    private

    def article_params
      params.permit(:kbid, :enabled, questions:[], answers:[:links, :metadata, :text, :active])
    end

    def articles
      Article.where(  where      )
             .order(  kbid:'ASC' )
             .offset( offset     )
             .limit(  PAGE_LIMIT )
             .map { |a| format_one a }
    end

    def where
      params[ :kbid ].present? ? { kbid:params[ :kbid ] } : {}
    end

    def offset
      page = params[ :page ].to_i
      page = 1 if page < 1

      ( page - 1 ) * 10
    end

    def format_one article
      { kbid:      article.kbid,
        enabled:   article.enabled,
        answers:   article.answers.map( &:serialize ),
        questions: article.questions.pluck( :text ) }
    end

    def save_associations article, questions, answers
      questions.to_a.each { |q| article.questions.create(text: q) }
      answers.to_a.each { |a| article.answers.create( a ) }
    end

    def delete_associations article
      article.answers.delete_all
      article.questions.delete_all
    end
  end
end
