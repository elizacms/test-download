module FAQ
  class APIController < ApplicationController
    PAGE_LIMIT = 10

    def get_articles
      total = Article.count
      pages = total / PAGE_LIMIT + 1

      body = { total:   total,
               pages:   pages,
               results: articles }

      render json:body.to_json
    end

    def put_articles
      article = Article.find_by(kbid: article_params[:kbid])

      unless article
        headers['Warning'] = 'No article found. You must send an existing kbid.'
        render body:{}.to_json, status: 404
        return
      end

      article.answers.delete_all
      article.questions.delete_all

      if article_params[:answers]
        article_params[:answers].each do |a|
          article.answers.create( text: a[:text],
                                  metadata: a[:metadata],
                                  links: a[:links],
                                  active: a[:active] )
        end
      end

      if article_params[:questions]
        article_params[:questions].each {|q| article.questions.create(text: q) }
      end

      article.update( enabled: article_params[ :enabled ] )

      render body:{}.to_json, status: 200
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
  end
end
