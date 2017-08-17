def response_hash
  { isFaq: "FALSE",
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
    versionId: "5" }
end

FactoryGirl.define do
  factory :article, class:FAQ::Article do
    kbid 123
    query 'wireless'
    response response_hash
  end
end
