require 'optparse'

module GitPair
  module Command

    def self.run!(args)
      banner = "\n#{GitPair::C_REVERSE} General Syntax: #{GitPair::C_RESET}"
      parser = OptionParser.new do |opts|
        opts.banner = banner
        opts.separator "  git pair [reset | authors | options]"

        opts.separator " "
        opts.separator ["#{GitPair::C_REVERSE} Options: #{GitPair::C_RESET}"]
        opts.on("-a", "--add NAME",    'Add an author. Format: "Author Name <author@example.com>"')    { |name| GitPair::Commands.add name }
        opts.on("-r", "--remove NAME", "Remove an author. Use the full name.") { |name| GitPair::Commands.remove name }

        opts.separator " "
        opts.separator ["#{GitPair::C_REVERSE} Switching authors: #{GitPair::C_RESET}",
                        "  git pair AA [BB]                   Where AA and BB are any abbreviation of an",
                        " "*37 + "author's name. You can specify one or more authors."]

        opts.separator " "
        opts.separator ["#{GitPair::C_REVERSE} Resetting authors: #{GitPair::C_RESET}",
                        "  git pair reset                     Reverts to the user specified in your Git configuration."]

        opts.separator " "
        opts.separator ["#{GitPair::C_REVERSE} Current config: #{GitPair::C_RESET}",
                        *(GitPair::Helpers.display_string_for_config.split("\n") + [" "] +
                          GitPair::Helpers.display_string_for_current_info.split("\n"))]
      end

      unused_options = parser.parse!(args).dup

      if GitPair::Commands.config_change_made?
        puts GitPair::Helpers.display_string_for_config
      elsif unused_options.include?('reset')
        GitPair::Commands.reset
        puts GitPair::Helpers.display_string_for_current_info
      elsif unused_options.any?
        GitPair::Commands.switch(unused_options)
        puts GitPair::Helpers.display_string_for_current_info
      else
        puts parser.help
      end

    rescue OptionParser::MissingArgument
      GitPair::Helpers.abort "missing required argument", parser.help
    rescue OptionParser::InvalidOption, OptionParser::InvalidArgument => e
      GitPair::Helpers.abort e.message.sub(':', ''), parser.help
    rescue GitPair::NoMatchingAuthorsError => e
      GitPair::Helpers.abort e.message, "\n" + GitPair::Helpers.display_string_for_config
    rescue GitPair::MissingConfigurationError => e
      GitPair::Helpers.abort e.message, parser.help
    end
  end
end
