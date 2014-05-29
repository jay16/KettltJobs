require "cgi"

def raw str
  CGI.unescapeHTML str
end

def extract_sql_from_ktr(ktr_path)
  ktr_str = IO.read(ktr_path)
  result = "--## ktr_file: #{File.basename(ktr_path)}  timestamp:#{Time.now.strftime('%Y/%m/%d %H:%M:%S')}\n"

  # global connection
  r_connection = /<name>(.*?)<\/name>\s+<server>(.*?)<\/server>\s+<type>(.*?)<\/type>\s+<access>(.*?)<\/access>\s+<database>(.*?)<\/database>\s+<port>(.*?)<\/port>\s+<username>(.*?)<\/username>\s+<password>(.*?)<\/password>/
  m_connection = ktr_str.scan(r_connection)

  result << "\n--#connection size: #{m_connection.size}\n"
  m_connection.each_with_index do |d, index|
    result << "--#connection#{index}\n"
    result << "--#   name     : #{raw d[0]}\n"
    result << "--#   server   : #{raw d[1]}\n"
    result << "--#   type     : #{raw d[2]}\n"
    result << "--#   access   : #{raw d[3]}\n"
    result << "--#   database : #{raw d[4]}\n"
    result << "--#   port     : #{raw d[5]}\n"
    result << "--#   username : #{raw d[6]}\n"
    result << "--#   password : #{raw d[7]}\n"
  end

  # local sql
  r_sql = /<connection>(.*?)<\/connection>\s+<sql>(.*?)<\/sql>/
  m_sql = ktr_str.scan(r_sql)
  result << "\n--#TableInput size: #{m_sql.size}\n"
  m_sql.each_with_index do |d, index|
    result << "--#TableInput#{index}\n"
    result << "--#   connection: #{raw d[0]}\n"
    result << "--#   sql:\n"
    result << raw(d[1])
    result << "\n"
  end

  # sql string
  r_string = /<connection>(.*?)<\/connection>\s+<execute_each_row>(.*?)<\/execute_each_row>\s+<single_statement>(.*?)<\/single_statement>\s+<replace_variables>(.*?)<\/replace_variables>\s+<quoteString>(.*?)<\/quoteString>\s+<sql>(.*?)<\/sql>/
  m_string = ktr_str.scan(r_string)
  result << "\n--#ExecSql size: #{m_string.size}\n"
  m_string.each_with_index do |d, index|
    result << "--#ExecSql#{index}\n"
    result << "--#   connection: #{raw d[0]}\n"
    result << "--#   sql:\n"
    result << raw(d[-1])
    result << "\n"
  end
  result
end

pwd = Dir.pwd
Dir.entries(pwd).grep(/\.ktr$/).each do |ktr_file|
  sql_file = ktr_file.sub(".ktr", ".sql")
  ktr_path = File.join(pwd, ktr_file)
  sql_path = File.join(pwd, "ktr_sql", sql_file)
  File.open(sql_path, "w+") do |file|
    file.puts extract_sql_from_ktr(ktr_path)
  end
end
