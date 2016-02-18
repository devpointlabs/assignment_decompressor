def unpack(file, folder)
  `mv #{file} students/#{folder}`
  `unzip students/#{folder}/#{file} -d students/#{folder}`
  `rm students/#{folder}/#{file}`
end

def git_clone(file, folder)
  url_line = File.open file do |x|
    x.find { |line| line =~ /github.com/ }
  end
  usr_repo = url_line.split('github.com/').last.split("\"")[0]
  clone_url = "git@github.com:#{usr_repo}.git"
  `git clone #{clone_url} students/#{folder}/#{usr_repo.split("/").last}`
  `rm #{file}`
end

if `ls`.split("\n").include?('submissions.zip')
  puts "Unzipping submissions.zip"
  `unzip submissions.zip`
  puts "Unzipped"
  files = `ls`.split("\n").reject! { |x| (x == 'assignment_unzip.rb') || (x == 'submissions.zip') || (x == 'students') || (x == 'README.md')}
  puts "#{files.count} student submissions found."
  folders = `ls students`.split("\n")
  files.each do |file|
    a = file.split('-').include?('') ? file.split('-').reject! { |x| x == '' } : file.split('-')
    folder = "#{a[0].split('_')[0]}_#{a.shift}"
    extension = file.split('.').last.downcase
    if folders.include?(folder)
      puts "#{folder} exists"
      if extension == 'zip'
        unpack(file, folder)
      elsif extension == 'html'
        git_clone(file, folder)
      end
    else
      puts "#{folder} does not yet exist. creating student folder."
      `mkdir students/#{folder}`
      if extension == 'zip'
        unpack(file, folder)
      elsif extension == 'html'
        git_clone(file, folder)
      end
    end
  end
  `rm submissions.zip`
  puts "submissions.zip deleted."
else
  puts "'submissions.zip' not found. Please move the submissions file to this directory."
end
