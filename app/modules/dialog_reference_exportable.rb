module DialogReferenceExportable
  def for_csv
    "{{intent:#{ intent_reference }}}"
  end
end