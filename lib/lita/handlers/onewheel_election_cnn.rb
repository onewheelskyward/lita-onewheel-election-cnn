require 'rest-client'

module Lita
  module Handlers
    class OnewheelElectionCnn < Handler
      route /^e[rl]ection$/i,
            :election,
            command: true,
            help: {'election' => 'Display the current election results.'}

      route /^e$/i,
            :election,
            command: true

      route /^e[rl]ection\s+(.*)$/i,
            :election_by_state,
            command: true,
            help: {'election AB' => 'Display the current election results in Alabama.'}

      route /^e\s+(.*)$/i,
            :election_by_state,
            command: true

      def election(response)
        Lita.logger.debug 'Getting election data'
        results = JSON.parse(RestClient.get('http://data.cnn.com/ELECTION/2016/full/P.full.json'))

        results['candidates'].each do |candidate|
          candidate_str = "#{candidate['fname']} #{candidate['lname']}: "
          candidate_str += "#{candidate['pctDecimal']}%"
          candidate_str += " WINNER! #{candidate['evotes']} electoral votes." if candidate['winner']
          Lita.logger.debug "Replying with #{candidate_str}"
          response.reply candidate_str
        end
      end

      def election_by_state(response)
        Lita.logger.debug 'get_source started'
        results = JSON.parse(RestClient.get('http://data.cnn.com/ELECTION/2016/full/P.full.json'))

        state = stateness(response.matches[0][0])

        results['races'].each do |race|
          if race['state'].downcase == state.downcase
            state_reply = "#{state}, #{race['evotes']} electoral votes, #{race['pctsrep']}% reporting"
            response.reply state_reply
            Lita.logger.debug "Replying with #{state_reply}"
            race['candidates'].each do |candidate|
              candidate_str = "#{candidate['fname']} #{candidate['lname']}: "
              candidate_str += "#{candidate['pctDecimal']}%"
              candidate_str += " WINNER! #{candidate['evotes']} electoral votes." if candidate['winner']
              Lita.logger.debug "Replying with #{candidate_str}"
              response.reply candidate_str
            end
          end
        end
      end

      def stateness(gimme)
        states = {"AK" => "Alaska",
                        "AL" => "Alabama",
                        "AR" => "Arkansas",
                        "AS" => "American Samoa",
                        "AZ" => "Arizona",
                        "CA" => "California",
                        "CO" => "Colorado",
                        "CT" => "Connecticut",
                        "DC" => "District of Columbia",
                        "DE" => "Delaware",
                        "FL" => "Florida",
                        "GA" => "Georgia",
                        "GU" => "Guam",
                        "HI" => "Hawaii",
                        "IA" => "Iowa",
                        "ID" => "Idaho",
                        "IL" => "Illinois",
                        "IN" => "Indiana",
                        "KS" => "Kansas",
                        "KY" => "Kentucky",
                        "LA" => "Louisiana",
                        "MA" => "Massachusetts",
                        "MD" => "Maryland",
                        "ME" => "Maine",
                        "MI" => "Michigan",
                        "MN" => "Minnesota",
                        "MO" => "Missouri",
                        "MS" => "Mississippi",
                        "MT" => "Montana",
                        "NC" => "North Carolina",
                        "ND" => "North Dakota",
                        "NE" => "Nebraska",
                        "NH" => "New Hampshire",
                        "NJ" => "New Jersey",
                        "NM" => "New Mexico",
                        "NV" => "Nevada",
                        "NY" => "New York",
                        "OH" => "Ohio",
                        "OK" => "Oklahoma",
                        "OR" => "Oregon",
                        "PA" => "Pennsylvania",
                        "PR" => "Puerto Rico",
                        "RI" => "Rhode Island",
                        "SC" => "South Carolina",
                        "SD" => "South Dakota",
                        "TN" => "Tennessee",
                        "TX" => "Texas",
                        "UT" => "Utah",
                        "VA" => "Virginia",
                        "VI" => "Virgin Islands",
                        "VT" => "Vermont",
                        "WA" => "Washington",
                        "WI" => "Wisconsin",
                        "WV" => "West Virginia",
                        "WY" => "Wyoming"}

        search_state = gimme.upcase
        if search_state.length == 2
          Lita.logger.debug "Returning #{states[search_state.upcase]} for #{search_state}"
          states[search_state.upcase]
        else
          Lita.logger.debug "Returning #{search_state}"
          search_state
        end
      end

      Lita.register_handler(self)
    end
  end
end
