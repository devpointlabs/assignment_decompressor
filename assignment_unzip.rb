require 'pry'

def unpack(file, folder)
  `mv #{file} students/#{folder}`
  `unzip students/#{folder}/#{file} -d students/#{folder}`
  `rm students/#{folder}/#{file}`
end

def git_clone(file, folder)
  begin
    url_line = File.open file do |x|
      x.find { |line| line =~ /github.com/ }
    end
    usr_repo = url_line.split('github.com/').last.split("\"")[0]
    clone_url = "git@github.com:#{usr_repo}.git"
    response = `git clone #{clone_url} students/#{folder}/#{usr_repo.split("/").last} 2>&1`
    if response.include?('already exists') || `ls students/#{folder}`.split("\n").include?("#{clone_url.split('/')[1]}")
      puts "#{emoji('talk')} this submission has already been cloned."
    elsif response.include?('not a valid repository name')
      puts "#{emoji('talk')} user did not submit a base repository url."
      puts "#{emoji('talk')} tried to clone from #{clone_url}"
      puts "#{emoji('talk')} attempting to find base url and clone."
      new_clone = clone_url.split('/')[0..1].join('/') + '.git'
      puts "#{emoji('talk')} new url: #{new_clone}"
      response2 = `git clone #{new_clone} students/#{folder}/#{clone_url.split('/')[1]} 2>&1`
      if response2.split(' ')[0] == 'Cloning'
        puts "#{emoji('talk')} assignment successfully cloned."
      else
        puts "#{emoji('error')} assignment could not be cloned."
      end
    else
      puts "#{emoji('good')} submisison successfully cloned"
    end
    `rm #{file}`
  rescue
    puts "#{emoji('error') * 3} #{folder} did not submit a link to github: link will not be destroyed."
  end
end

def emoji(type)
  e = {
    'destroy' => "\u{1F525} ",
    'error' =>"\u{1F480} ",
    'poo' => "\u{1F4A9} ",
    'talk' => "\u{1F4AC} ",
    'eggplant' => "\u{1F346} ",
    'bolt' => "\u{26A1} ",
    'alien' => "\u{1F47E} ",
    'good' => "\u{1F44D} "
  }
  e[type]
end

def zip_or_clone(file, folder, extension)
  if extension == 'zip'
    unpack(file, folder)
  elsif extension == 'html'
    git_clone(file, folder)
  end
end

def extract_work(file, folders)
  a = file.split('-').include?('') ? file.split('-').reject! { |x| x == '' } : file.split('-')
  last_name = a.shift
  first_name = a[0].split('_')[0]
  folder = "#{first_name}_#{last_name}"
  extension = file.split('.').last.downcase
  if folders.include?(folder)
    puts "#{emoji('bolt') * 3} #{folder} exists"
    zip_or_clone(file, folder, extension)
  else
    puts "#{emoji('poo') * 3} #{folder} does not yet exist. creating student folder."
    `mkdir students/#{folder}`
    zip_or_clone(file, folder, extension)
  end
end

def decompress_assignment
  current_files = `ls`.split("\n")
  puts "#{emoji('talk')} Unzipping submissions.zip"
  `unzip submissions.zip`
  files = `ls`.split("\n") - current_files
  if files.include?('submissions')
    `mv submissions/* .`
    files.delete('submissions')
    files = `ls`.split("\n") - current_files
  end
  puts "#{emoji('talk')} #{files.count} student submissions found."
  folders = `ls students`.split("\n")
  files.each do |file|
    extract_work(file, folders)
  end
  `rm submissions.zip`
  puts "#{emoji('destroy') * 3} submissions.zip deleted. #{emoji('destroy') * 3}"
end

def sub_not_found
  puts "#{(emoji('error') + emoji('alien')) * 20}\n'submissions.zip' not found. Please move the submissions file to this directory.\n#{(emoji('alien') + emoji('error')) * 20}"
end

def main
  if `ls`.split("\n").include?('submissions.zip')
    decompress_assignment
  else
    sub_not_found
  end
end

main
