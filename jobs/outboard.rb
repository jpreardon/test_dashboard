require 'net/http'
require 'uri'

# :first_in sets how long it takes before the job is first run. In this case, it is run immediately
SCHEDULER.every '1m', :first_in => 0 do |job|
  begin
    # Fetch the file
    uri = URI(settings.outboard_file)
    # Put the file contents into an array, force encoding and delete is here to support Google Drive files
    people = Net::HTTP.get_response(uri).body.force_encoding('UTF-8').encode('UTF-8').delete("^\u{0000}-\u{007F}").split(/\n|\r\n/)

    # Create an array to hold the values we are sending back to the widget
    values = Array.new

    # Sort the array (by name)
    people.sort!

    people.each do |line|
      # Ignore comments and blank lines
      # also ensure there's at least one delimiter and data
      if !line.match(/^\s*(#|$)/) && line.match(/.\|./)

        # Split the line into an array and populate variables
        person = line.split('|')
        name = person[0].strip.force_encoding('UTF-8')
        givenstatus = person[1].strip.force_encoding('UTF-8')

        # Convert the person's status to a cute icon, default to "out"

        # These are Font Awesome icons, the icons used below can be swapped for
        # any of the ones defined by the font-awsome.css. View all the available
        # icons here: http://fortawesome.github.io/Font-Awesome/3.2.1/icons/

        # Be totally insensitive, to case
        case givenstatus.downcase
        when 'wah'
          icon = 'icon-home'
          status = 'in'
        when 'vacation'
          icon = 'icon-plane'
          status = 'out'
        when 'in'
          icon = 'icon-star'
          status = 'in'
        when "offsite"
          icon = 'icon-glass'
          status = 'in'
        else
          icon = 'icon-remove'
          status = 'out'
        end

        # If a comment exists, get it
        if person[2]
          comment = person[2].force_encoding('UTF-8')
        end

        # Push the status into the array
        values.push({ :name => name, :status => status, :comment => comment, :icon => icon })
      end
    end

    # Send to dashboard
    send_event('outboard', :values => values)
  rescue NoMethodError => err
    puts "outboard.rb: Something's wrong with the text input file. Check your text file and make sure it's referenced in your config.ru file"
  rescue => err
    puts "outboard.rb: #{err}"
  end
end
