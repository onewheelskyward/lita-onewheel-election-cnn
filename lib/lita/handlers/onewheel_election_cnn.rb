require 'rest-client'

module Lita
  module Handlers
    class OnewheelElectionCnn < Handler
      route /^e[rl]ection/i,
            :election,
            command: true,
            help: {'election' => 'Display the current election results.'}

      def election(response)
        Lita.logger.debug 'get_source started'
        results = JSON.parse(RestClient.get('http://data.cnn.com/ELECTION/2016/full/P.full.json'))

        results['candidates'].each do |candidate|
          candidate_str = "#{candidate['fname']} #{candidate['lname']}: "
          candidate_str += "WINNER! " if candidate['winner']
          candidate_str += "#{candidate['pctDecimal']}%, #{candidate['vpct']}% of precincts reporting."
          response.reply candidate_str
        end
      end
      Lita.register_handler(self)
    end
  end
end
