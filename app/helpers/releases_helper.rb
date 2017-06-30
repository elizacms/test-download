module ReleasesHelper
  def diff_format single_diff
    old_formatted = single_diff[:file_type] == 'Eliza_de' ? json_pretty_for( single_diff[:old] ) : single_diff[:old].force_encoding('ISO-8859-1')
    new_formatted = single_diff[:file_type] == 'Eliza_de' ? json_pretty_for( single_diff[:new] ) : single_diff[:new].force_encoding('ISO-8859-1')

    Diffy::SplitDiff.new(old_formatted, new_formatted,
                          format: :html,
                          include_plus_and_minus_in_html: true,
                          context: 0)
  end

  def json_pretty_for content
    JSON.pretty_generate JSON.parse content
  rescue
    ""
  end
end
