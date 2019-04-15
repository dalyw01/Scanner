# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Author : william.daly@bbc.co.uk
# Desc   : This is the file you execute to initialise Scanner and for it to grab + print content
#          Once complete this script will generate "index.html" 
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

require_relative 'ScannerHTML.rb'

scanner = ScannerHTML.new
scanner_json = ScannerJSON.new

iplayer_total = scanner.getIplayerTotalVpids()

puts "x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x"
puts "                          Scanner has been initiated!                              "
puts "x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x"

puts "x x x x x x x x x x x x x x"
puts "Creating <HTML/> file!"
puts "x x x x x x x x x x x x x x"

scanner.addHTMLheader()
scanner.printNewsVpidsFromLink( "News - Front Page"		    , "http://A-FUNNY-DOMAIN/news_front_page"    )
scanner.printNewsVpidsFromLink( "News - Most Popular"       , "http://A-FUNNY-DOMAIN/most_popular/news" 	 )
scanner.printNewsVpidsFromLink( "News - Technology"         , "http://A-FUNNY-DOMAIN/technology" 	 )
scanner.printNewsVpidsFromLink( "News - Politics"           , "http://A-FUNNY-DOMAIN/politics" 	 )
scanner.printNewsVpidsFromLink( "News - Mundo Front Page"   , "http://A-FUNNY-DOMAIN/front_page" 	 )
scanner.printNewsVpidsFromLink( "News - Russian Front Page" , "http://A-FUNNY-DOMAIN/russia" )

scanner.printIplayerVpidsFromLink( "iPlayer - Most Popular (Ranked by plays)" , "http://A-FUNNY-DOMAIN/plays" , "group_episodes" , ""   )
scanner.printIplayerVpidsFromLink( "iPlayer - Not Very Popular" , "http://A-FUNNY-DOMAIN/episodes?per_page=20&page=#{(iplayer_total / 20) / 2}" , "group_episodes" , "" )
scanner.printIplayerVpidsFromLink( "iPlayer - Least Popular"    , "http://A-FUNNY-DOMAIN/episodes?per_page=20&page=#{iplayer_total / 20}"       , "group_episodes" , "" )
scanner.printIplayerVpidsFromLink( "iPlayer - Guidance"         , "http://A-FUNNY-DOMAIN/episodes" , "group_episodes" , "guidance"   )
scanner.printIplayerVpidsFromLink( "iPlayer - Signed"   , "http://A-FUNNY-DOMAIN/signed"  , "category_programmes"  , "signed" )
scanner.printIplayerVpidsFromLink( "iPlayer - Cbeebies" , "http://A-FUNNY-DOMAIN/channels/cbeebies/episodes" , "channel_programmes"    , "" )
scanner.printIplayerVpidsFromLink( "iPlayer - S4C"      , "http://A-FUNNY-DOMAIN/channels/s4c/episodes"      , "channel_programmes"  , "" )

scanner.printStats()
scanner.addNavBarLinks()
scanner.addHTMLFooter()


puts "x x x x x x x x x x x x x x x x x x x x x x x x x x x x"
puts "Scanner has finished! Come again! ^____^ ^____^ ^____^"
puts "x x x x x x x x x x x x x x x x x x x x x x x x x x x x"