module ReleasesHelper
  def diff
    old_formatted = json_pretty_for @diff[:old]
    new_formatted = json_pretty_for @diff[:new]

    Diffy::SplitDiff.new(old_formatted, new_formatted, format: :html, context: 0)
  end

  def json_pretty_for content
    JSON.pretty_generate JSON.parse content
  end
end