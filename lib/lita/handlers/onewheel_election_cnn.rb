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

        response.reply "\x0300United States 2016 Presidential Election, #{results['races'][0]['pctsrep']}% reporting."
        votes = {'blue' => {}, 'red' => {}}
        results['candidates'].each do |candidate|
          if candidate['lname'] == 'Clinton'
            votes['blue']['percentage'] = candidate['pctDecimal']
            votes['blue']['popular']    = candidate['cvotes']
            votes['blue']['electoral']  = candidate['evotes']
            votes['blue']['winner']     = candidate['winner']
          end

          if candidate['lname'] == 'Trump'
            votes['red']['percentage'] = candidate['pctDecimal']
            votes['red']['popular']    = candidate['cvotes']
            votes['red']['electoral']  = candidate['evotes']
            votes['red']['winner']     = candidate['winner']
          end
        end

        blueredstr = get_blueredstr(votes)
        response.reply "\x0300Clinton #{votes['blue']['percentage']}% #{votes['blue']['popular']} |#{blueredstr}\x0300| Trump #{votes['red']['percentage']}% #{votes['red']['popular']}"

        ansielection(response, results)
      end

      def get_blueredstr(votes)
        bluecount = (votes['blue']['percentage'].to_f / 2).to_i
        redcount = (votes['red']['percentage'].to_f / 2).to_i

        blueredstr = "\x0312"
        bluecount.times { blueredstr += '█' }
        blueredstr += "\x0300"
        (50 - bluecount - redcount).times { blueredstr += '-' }
        blueredstr += "\x0304"
        redcount.times { blueredstr += '█' }
        blueredstr
      end

      def election_by_state(response)
        Lita.logger.debug 'get_source started'
        results = JSON.parse(RestClient.get('http://data.cnn.com/ELECTION/2016/full/P.full.json'))

        state = stateness(response.matches[0][0])
        votes = {'blue' => {}, 'red' => {}}

        results['races'].each do |race|
          if race['state'].downcase == state.downcase
            state_reply = "\x0300#{state}, #{race['evotes']} electoral votes, #{race['pctsrep']}% reporting"
            response.reply state_reply
            Lita.logger.debug "Replying with #{state_reply}"
            race['candidates'].each do |candidate|
              if candidate['lname'] == 'Clinton'
                votes['blue']['percentage'] = candidate['pctDecimal']
                votes['blue']['popular']    = candidate['cvotes']
                votes['blue']['electoral']  = candidate['evotes']
                votes['blue']['winner']     = candidate['winner']
              end

              if candidate['lname'] == 'Trump'
                votes['red']['percentage'] = candidate['pctDecimal']
                votes['red']['popular']    = candidate['cvotes']
                votes['red']['electoral']  = candidate['evotes']
                votes['red']['winner']     = candidate['winner']
              end
            end

            blueredstr = get_blueredstr(votes)
            response.reply "\x0300Clinton #{(votes['blue']['winner'] == true)? ' WINNER! ' : '' }#{votes['blue']['percentage']}% #{votes['blue']['popular']} |#{blueredstr}\x0300| Trump #{votes['red']['percentage']}% #{votes['red']['popular']}"
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
                        "DC" => "Dist. of Columbia",
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

      def ansielection(response, results)
        reds = 0
        blues = 0
        results['candidates'].each do |candidate|
          if candidate['lname'] == 'Clinton'
            blues = candidate['evotes']
          end
          if candidate['lname'] == 'Trump'
            reds = candidate['evotes']
          end
        end

        reply = ''
        extras = 54 - (blues / 10) - (reds / 10)
        reply += "\x0312"
        (blues / 10).times { reply += '█' }
        reply += "\x0300"
        extras.times { reply += '-'}
        reply += "\x0304"
        (reds / 10).times { reply += '█' }

        reply.insert((reply.length / 2) + 3, "👽")

        reply = "\x0300Clinton #{blues} |" + reply + "\x0300| Trump #{reds}"

        response.reply reply
      end

      Lita.register_handler(self)
    end
  end
end
