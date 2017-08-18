module FAQ
  class APIController < ApplicationController
    PAGE_LIMIT = 10

    def get_articles
      total = Article.count
      pages = total / PAGE_LIMIT + 1

      body = { total:   total,
               pages:   pages        ,
               results: articles     }

      render json:body.to_json
    end

    def put_articles
      Article.update_for params

      render body:'{}'
    end


    private

    def articles
      Article.where( where      )
             .order( kbid:'ASC' )
             .offset( offset )
             .limit( PAGE_LIMIT )
             .map do | a |
               format_one a
             end
    end

    def where
      params[ :kbid ].present? ?
        { kbid:params[ :kbid ]}
      :
        {}
    end

    def offset
      page = params[ :page ].to_i
      page = 1 if page < 1

      ( page -1 ) * 10
    end

    def format_one article
       { kbid:     article.kbid,
         enabled:  article.enabled,
         questions:article.questions.pluck( :text ),
         answers:  article.answers.map( &:serialize )}
    end
  end
end