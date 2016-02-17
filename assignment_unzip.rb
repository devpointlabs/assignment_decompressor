if `ls`.split("\n").include?('submissions.zip')
  puts "Unzipping submissions.zip"
  `unzip submissions.zip`
  puts "Unzipped"
  files = `ls`.split("\n").reject! { |x| (x == 'assignment_unzip.rb') || (x == 'submissions.zip') || (x == 'students')}
  puts "#{files.count} student submissions found."
  folders = `ls students`.split("\n")
  files.each do |file|
    a = file.split('-').include?('') ? file.split('-').reject! { |x| x == '' } : file.split('-')
    last_name = a.shift
    first_name = a[0].split('_')[0]
    folder = "#{first_name}_#{last_name}"
    if folders.include?(folder)
      puts "#{folder} exists"
      `mv #{file} students/#{folder}`
      `unzip students/#{folder}/#{file} -d students/#{folder}`
      `rm students/#{folder}/#{file}`
    else
      puts "#{folder} does not yet exist. creating student folder."
      `mkdir students/#{folder}`
      `mv #{file} students/#{folder}`
      `unzip students/#{folder}/#{file} -d students/#{folder}`
      `rm students/#{folder}/#{file}`
    end
  end
  `rm submissions.zip`
  puts "submissions.zip deleted."
else
  puts "'submissions.zip' not found. Please move the submissions file to this directory."
end
