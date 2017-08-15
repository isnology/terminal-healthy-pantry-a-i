bitmap = ["11111",
          "1   1",
          " 111 ",
          "1  1 ",
          " 11 1"]

char = '&'
cmd = "#{char}: ["
bitmap.each do |str|
  cmd << "["
  4.times do |x|
    cmd << "'#{str[x]}',"
  end
  cmd << "'#{str[4]}'],"
end
cmd << "],"
puts cmd
