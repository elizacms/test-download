module FAQ
  class APIController < ApplicationController
    PAGE_LIMIT = 10

    def get_articles
      articles = Article.collection.aggregate( pipeline )

      kbids = Article.distinct( :kbid ).count

      pages = kbids / PAGE_LIMIT + 1

      body = { total:   kbids    ,
               pages:   pages    ,
               results: articles }

      render json:body.to_json
    end

    def put_articles
      Article.update_for params

      render body:'{}'
    end


    private

    def pipeline
      params[ :kbid ].present? ?
        [ match, project, project2, group, cleanup ] :
        [ project, project2, group, sort, skip, limit, cleanup ]
    end

    def match
      { '$match':{ kbid:params[ :kbid ].to_i }}
    end

    def sort
      { '$sort':{ _id: 1 }}
    end

    def project
      { '$project':
         { kbid: '$kbid', 
           query: '$query', 
           answers:{ '$arrayElemAt':[ '$response.Answers', 0 ]}} }
    end

    def project2
      { '$project':{ kbid:     '$kbid' ,
                     _id:       false,
                     article: { query:    '$query',
                                response: '$answers.Answer' }}}
    end

    def group
      { '$group':{ _id:  '$kbid',
                   articles:{ '$push': '$article' }}}
    end

    def cleanup
      { '$project':{ kbid:      '$_id' ,
                     articles:   true  ,
                     _id:        false }}
    end

    def limit
      { '$limit': PAGE_LIMIT }
    end

    def skip
      page = params[ :page ].to_i
      page = 1 if page < 1

      number = ( page -1 ) * 10

      { '$skip': number } 
    end
  end
end