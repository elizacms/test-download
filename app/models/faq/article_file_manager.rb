module FAQ
  class ArticleFileManager
    RESPONSE_TYPE = 4

    include FilePath

    def import
      CSV.open( faq_article_file )
         .select( &:any? )
         .each do | query, hash |
            create_for query, hash
         end
    end

    def export
      CSV.open( faq_article_file, 'wt' ) do | csv |
        Article.each do | a |
          dup = a.response.dup

          # Move versionId to end of hash to match existing format
          dup[ :versionId ] = dup.delete( :versionId )

          response = { ResponseValue:dup         ,
                       ResponseType:RESPONSE_TYPE }
          response_json = JSON.generate( response, space:' ' )
                              .gsub( ',"',   ', "' )
                              .gsub( ', ",', ',",' )
                              .gsub( ',{',   ', {' )

          csv << [ a.query, response_json ]
        end
      end
    end


    private

    def create_for query, hash
      response = JSON.parse( hash, symbolize_names:true )[ :ResponseValue ]
      
      params = { query:    query,
                 kbid:     response.delete( :id ),
                 response: response }

      Article.create! params
    end
  end
end