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
  response = `git clone #{clone_url} students/#{folder}/#{usr_repo.split("/").last} 2>&1`
  if response.include?('already exists')
    puts "#{emoji('talk')} this submission has already been cloned."
  elsif response.include?('not a valid repository name')
    puts "#{emoji('talk')} user did not submit a base repository url."
  else
    puts "#{emoji('good')} submisison successfully cloned"
  end
  `rm #{file}`
end

def emoji(type)
  case type
  when 'destroy'
    "\u{1F525} "
  when 'error'
    "\u{1F480} "
  when 'poo'
    "\u{1F4A9} "
  when 'talk'
    "\u{1F4AC} "
  when 'eggplant'
    "\u{1F346} "
  when 'bolt'
    "\u{26A1} "
  when 'alien'
    "\u{1F47E} "
  when 'good'
    "\u{1F44D} "
  end
end

if `ls`.split("\n").include?('submissions.zip')
  puts "#{emoji('talk')} Unzipping submissions.zip"
  `unzip submissions.zip`
  files = `ls`.split("\n").reject! { |x| (x == 'assignment_unzip.rb') || (x == 'submissions.zip') || (x == 'students') || (x == 'README.md')}
  puts "#{emoji('talk')} #{files.count} student submissions found."
  folders = `ls students`.split("\n")
  files.each do |file|
    a = file.split('-').include?('') ? file.split('-').reject! { |x| x == '' } : file.split('-')
    last_name = a.shift
    first_name = a[0].split('_')[0]
    folder = "#{first_name}_#{last_name}"
    extension = file.split('.').last.downcase
    if folders.include?(folder)
      puts "#{emoji('bolt') * 3} #{folder} exists"
      if extension == 'zip'
        unpack(file, folder)
      elsif extension == 'html'
        git_clone(file, folder)
      end
    else
      puts "#{emoji('poo') * 3} #{folder} does not yet exist. creating student folder."
      `mkdir students/#{folder}`
      if extension == 'zip'
        unpack(file, folder)
      elsif extension == 'html'
        git_clone(file, folder)
      end
    end
  end
  `rm submissions.zip`
  puts "#{emoji('destroy') * 3} submissions.zip deleted. #{emoji('destroy') * 3}"
else
  puts "#{(emoji('error') + emoji('alien')) * 20}\n'submissions.zip' not found. Please move the submissions file to this directory.\n#{(emoji('alien') + emoji('error')) * 20}"
end
