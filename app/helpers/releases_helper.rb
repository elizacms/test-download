module ReleasesHelper
  def diff_format single_diff
    if single_diff[:file_type] == 'Eliza_de'
      new_formatted = json_pretty_for( single_diff[:new] )
      old_formatted = json_pretty_for( single_diff[:old] )
    else
      new_formatted = single_diff[:new].force_encoding('UTF-8')
      old_formatted = single_diff[:old].force_encoding('UTF-8')
    end

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
