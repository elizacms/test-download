class FileManager
  include FilePath

  def load_file
    CSV.read( file ).select &:any?
  end

  def append *data
    file_data = File.read( file ).strip
    
    file_data << "\n#{ data.join ',' }\n"
    
    File.write( file, file_data )
  end

  def update row_num, *data
    lines = File.read( file ).lines.map &:strip

    lines[ row_num.to_i ] = "#{ data.join ',' }"

    File.write( file, lines.join( "\n" ))
  end
end
