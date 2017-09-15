describe 'FAQ::ArticleFileManager' do
  let( :file_manager  ){ FAQ::ArticleFileManager.new  }
  let( :faq_export_file ){ faq_article_file }
  let( :expected_export ){ %Q~What is wrong with my phone?,"{""ResponseValue"": {""isFaq"": ""FALSE"",""Answers"": [{""Answers"": {""outputMetaData"": {},""isDefault"": ""TRUE"",""Answer"": ""Hierbei werden Contents gesperrt, die nur für die Einsicht für über 18-Jährige bestimmt sind. Wir sichern somit Ihr Kind vor nicht geeigneten Seiten und mehr! Weiters werden Zugänge bzw. die Vorschau von Bildern, Videos oder Menüs, welche für über 18-Jährige bestimmt sind, gesperrt.""}}],""id"": 123},""ResponseType"": 4}"\n~ }
  

  let!( :article  ){ create :article }
  let!( :question ){ create :question, article:article }
  let!( :answer   ){ create :answer,   article:article }

  specify 'Export dialogs' do
    file_manager.export

    expect( File.read( faq_export_file )).to eq expected_export
  end
end
