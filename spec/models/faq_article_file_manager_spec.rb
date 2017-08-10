describe 'FAQ::ArticleFileManager' do
  let( :file_manager  ){ FAQ::ArticleFileManager.new }
  let( :first_article ){ FAQ::Article.first }
  let( :expected_response ){{ isFaq: "FALSE",
                              Answers: [
                                {
                                  outputMetaData: {
                                    emotion: "neutral"
                                  },
                                  isDefault: "TRUE",
                                  Answer: "Hierbei werden Contents gesperrt, die nur für die Einsicht für über 18-Jährige bestimmt sind. Wir sichern somit Ihr Kind vor nicht geeigneten Seiten und mehr! Weiters werden Zugänge bzw. die Vorschau von Bildern, Videos oder Menüs, welche für über 18-Jährige bestimmt sind, gesperrt.",
                                  dimensionsValues: ""
                                }
                              ],
                              Qid: "1",
                              Categories: [
                                {
                                  id: 2,
                                  sortOrder: nil
                                },
                                {
                                  id: 30,
                                  sortOrder: nil
                                },
                                {
                                  id: 106,
                                  sortOrder: nil
                                },
                                {
                                  id: 514,
                                  sortOrder: nil
                                }
                              ],
                              culture: "de",
                              id: "442",
                              versionId: "5" }}
  let( :article_file ){ Object.new.extend( FilePath ).faq_article_file }

  before do
    FileUtils.copy 'spec/data-files/german-faq-full.csv', article_file
  end

  specify 'Import dialogs' do
    file_manager.import

    expect( FAQ::Article.count ).to eq   4958
    expect( first_article.query ).to eq 'Fsk.'
    expect( first_article.kbid  ).to eq  442
    
    expect( first_article.response ).to eq expected_response
  end

  specify 'Each response has 1 answer' do
    file_manager.import

    expect( FAQ::Article.all.map{| a | a.response[ :Answers ].count }.uniq ).to eq [ 1 ]
  end

  specify 'Export dialogs' do
    file_manager.import

    FileUtils.rm article_file

    file_manager.export

    expect( File.read 'spec/data-files/german-faq-full.csv' ).to eq File.read( article_file )
  end
end
