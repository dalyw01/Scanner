# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Author : william.daly@bbc.co.uk
# Desc   : This is the Ruby file used to generate a user-friendly HTML file output
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

require "net/http"
require "uri"
require "json"
require 'base64'
require 'time'

class ScannerHTML

  #---------------------------------------------------------------------------------

  def initialize()
    @index, @nav_bar_links, @iplayer_stats, @news_stats = 0 , [] , Hash.new(0), Hash.new(0)
  end

  #---------------------------------------------------------------------------------

  def addHTMLheader()
    @fileHtml = File.new("generated_files/index.html", "w+")
    t = Time.now
    @fileHtml.puts '
    <html>
      <head>
        <title>BBC Scanner</title>
        <link rel="stylesheet" type="text/css" href="styling/index.css"/>
        <meta charset="UTF-8">
      </head>
      <div id="nav_bar">
        <h1><a href="#"><img id="bbc_logo" src="images/bbc_logo.jpeg"/> Scanner</a></h1>
      </div>
      <div id="wrapper">
        <p>Welcome!</p>
        <p>Scanner outputs current video + audio vpids on iPlayer and News!</p>
        <p>Any queries please contact <b>william.daly----@bbc-----.co.uk</b></p>'
        @fileHtml.puts "<p>Latest scan took place at <div id='scan_time'>#{Time.now.strftime("%A %e  %B %Y at %l:%M %p")}</div></p>"
  end

  #---------------------------------------------------------------------------------

  def addNavBarLinks()
    @fileHtml.puts "
    <div tabindex='0' id='drop_down'>
      <div id='links'>
          <p>Available links</p>
          <ul>"
    @nav_bar_links.each do |heading|
      @fileHtml.puts "<li><a href='##{heading.delete(' ')}'>#{heading}</a></li>"
    end
    @fileHtml.puts "</ul></div></div>"
  end

  #---------------------------------------------------------------------------------

  def addHTMLFooter()
    @fileHtml.puts '</body></html>'
  end

  #---------------------------------------------------------------------------------

  def printStats()
    @fileHtml.puts '<div id="stats_summary">'
    @fileHtml.puts "<p>Scanner has detected <strong>right now</strong> there are <strong>#{@index}</strong> clips with properties -</p>"
    printNewsStats()
    printIplayerStats()
    @fileHtml.puts "</div>"
  end

  #---------------------------------------------------------------------------------

  def printIplayerStats()
    @fileHtml.puts '<div id="iplayer_summary">'
    @fileHtml.puts "<h3>Iplayer</h3>"
    @fileHtml.puts "<ul>"
    @iplayer_stats = Hash[@iplayer_stats.map {|k,v| [k,v.to_s] }]
    temp = Hash[ @iplayer_stats.sort_by { |key, val| key } ] # Sort Keys alphabetically so easier to read in HTML output
    temp.each do |key,value|
      @fileHtml.puts "<li class='stat'>#{key} = #{value}</li>"
    end
    @fileHtml.puts "</ul></div>"
  end

  #---------------------------------------------------------------------------------

  def printNewsStats()
    @fileHtml.puts '<div id="news_summary">'
    @fileHtml.puts "<h3>News</h3>"
    @fileHtml.puts "<ul>"
    @news_stats.each do |key,value|
      if key != ""
        @fileHtml.puts "<li class='stat'>#{key} = #{value}</li>"
      end
    end
    @fileHtml.puts "</ul></div>"
  end

  #---------------------------------------------------------------------------------

  def printNewsHeader( new_title )
    @fileHtml.puts "<div id='#{new_title.delete(' ')}'>"
    @fileHtml.puts "<h2><img id='image_#{new_title.delete(' ')}' src='images/news_icon.jpeg'/> #{new_title}</h2>"
    @nav_bar_links.push("#{new_title}")
  end

  #---------------------------------------------------------------------------------

  def printIplayerHeader( new_title )
    @fileHtml.puts "<div id='#{new_title.delete(' ')}'>"
    @fileHtml.puts "<h2><img id='image_#{new_title.delete(' ')}'src='images/iplayer_icon.jpeg'/> #{new_title}</h2>"
    @nav_bar_links.push("#{new_title}")
  end

  #---------------------------------------------------------------------------------

  def getIplayerTotalVpids()
    @website_resp = Net::HTTP.get_response(URI.parse("http://A-FUNNY-DOMAIN/episodes"))
    @website_data = @website_resp.body
    @hash = JSON.parse(@website_data)
    return @hash["group_episodes"]["count"]
  end

  #---------------------------------------------------------------------------------

  def parseJSONFromLink( new_link ) 
    website_resp = Net::HTTP.get_response(URI.parse(new_link))
    website_data = (website_resp.code == '200') ? website_resp.body : '{}'
    return JSON.parse(website_data) # Returns a hash
  end

  #---------------------------------------------------------------------------------

  def createIplayerLink( new_parent_id , new_kind )
    if new_kind == "audio-described"
      @fileHtml.puts "<li class='iplayer_link'><a href='http://A-FUNNY-DOMAIN/episode/#{new_parent_id}/ad/' 
      target='_blank'>iPlayer Link</a></li>"
    elsif new_kind == "signed"
      @fileHtml.puts "<li class='iplayer_link'><ahttp://A-FUNNY-DOMAIN/episode/#{new_parent_id}/sign/' 
      target='_blank'>iPlayer Link</a></li>"
    else
      @fileHtml.puts "<li class='iplayer_link'><a href='http://A-FUNNY-DOMAIN/episode/#{new_parent_id}/'
      target='_blank'>iPlayer Link</a></li>"
    end
  end

  #---------------------------------------------------------------------------------

  def createIplayerKindFlag( new_kind )
    if new_kind == "audio-described"
      @fileHtml.puts "<li class='iplayer_kind_flag_ad'>AD</li>"
    elsif new_kind == "signed"
      @fileHtml.puts "<li class='iplayer_kind_flag_sl'>SIGN</li>"
    end
  end

  #---------------------------------------------------------------------------------

  def createNewsArticleLink( new_parent_id )
    @fileHtml.puts "<li class='news_link'><a href='#{new_parent_id.sub( "/cps" , "http://www.A-FUNNY-DOMAIN")}' target='_blank'>News Article Link</a></li>"
  end

  #---------------------------------------------------------------------------------

  def createCookBookLink( new_product , new_holding_image , new_title , new_guidance , new_vpid , new_kind )
    smp_settings =
    {
      'product' => new_product,
      'superResponsive' => true
    }

    smp_playlist =
    {
      'holdingImageURL' => new_holding_image,
      'title'           => new_title,
      'guidance'        => new_guidance,
      'items' =>
      [
        {
          'versionID' => new_vpid,
          'kind'      => new_kind
        }
      ]
    }

    encoded_settings = Base64.encode64(smp_settings.to_json).gsub("\n", '')
    encoded_playlist = Base64.encode64(smp_playlist.to_json).gsub("\n", '')
    @fileHtml.puts "<li class='cookbook_link'><a href='http://A-FUNNY-DOMAIN/cookbook/#{new_product}?settings=#{encoded_settings}&playlist=#{encoded_playlist}' target='_blank'>Push To Cookbook And Customise</a></li>"
  end

  #---------------------------------------------------------------------------------

  def createTestCookBookLink( new_product , new_holding_image , new_title , new_guidance , new_vpid , new_kind )
    
    smp_settings =
    {
      'product' => new_product,
      'superResponsive' => true,
      'startTime' => 5,
      'ui' => 
      {
        'controls' =>
        {
          'seekbarBackground' => 'linear-gradient(to right, #009246, #F1F2F1, #CE2B37)'
        },
        'guidance': 
        {
          'displayContinuousGuidanceInQueuePlaylist': true
        }
      }
    }

    smp_playlist =
    {
      'holdingImageURL' => new_holding_image,
      'title'           => "#{new_vpid}",
      'guidance'        => "This is GUIDANCE for #{new_vpid}",
      'items' =>
      [
        {
          'versionID' => new_vpid,
          'kind'      => new_kind
        }
      ],
      'queuedPlaylist' => 
      {
        'title'    => 'Audio §12§12§12§12§2§2',
        'warning'  => "This is a WARNING for Audio content",
        'items'    => 
        [
          {
            'versionID' => '1231231231223123',  # This is a short Audio clip to add some diversity to testing
            'kind'      => 'radioProgramme'
          },
        ],
        'queuedPlaylist' => 
        {
          'title'           => "Ident + #{new_vpid}",
          'holdingImageURL' => new_holding_image,
          'guidance'        => "This is GUIDANCE for #{new_vpid}",
          'items' => 
          [
            {
              'versionID' => '123456789011',
              'kind'      => 'ident'
            },
            {
              'versionID' => new_vpid,
              'kind'      => new_kind
            }
          ]
        }
      }
    }

    encoded_settings = Base64.encode64(smp_settings.to_json).gsub("\n", '')
    encoded_playlist = Base64.encode64(smp_playlist.to_json).gsub("\n", '')
    @fileHtml.puts "<li class='cookbook_link'><a href='http://A-FUNNY-DOMAIN/cookbook/#{new_product}?settings=#{encoded_settings}&playlist=#{encoded_playlist}' target='_blank'>Push To Cookbook And Customise</a></li>"
  end

  #---------------------------------------------------------------------------------

  def assignBackgroundImage( new_ichef_url  )
    if new_ichef_url =~ /\$recipe/
      holding_image = "#{new_ichef_url.sub("$recipe", "976x549")}"
      @fileHtml.puts "<div id='entry_#{@index}' class='entry_style' 
      style='background-image:linear-gradient(rgba(255,255,255,0.8),rgba(255,255,255,1.0)), url(#{holding_image})'>"

    elsif new_ichef_url =~ /{recipe}/i
      holding_image = "#{new_ichef_url.sub("{recipe}", "976x549")}"
      @fileHtml.puts "<div id='entry_#{@index}' class='entry_style' 
      style='background-image:linear-gradient(rgba(255,255,255,0.8),rgba(255,255,255,1.0)),url(#{holding_image})'>"

    # Else there's no image, keep the index incrementing but don't assign an image
    else
      @fileHtml.puts "<div id='entry_#{@index}' class='entry_style' 
      style='background-image:linear-gradient(rgba(255,255,255,0.8),rgba(255,255,255,1.0)), url(#{holding_image})'>"
    end

    # Return image so it can be later used to pass on to COOKBOOK
    return holding_image
  end

    #---------------------------------------------------------------------------------

  def printNewsVpidsFromLink( new_title , new_link )
    external_trevor_links = []
    entry_vpids = []
    
    news_hash = parseJSONFromLink( new_link ) 
    printNewsHeader( new_title )

    # Cycle through Hash and print info of each VPID
    news_hash.fetch("relations", []).each do |parent|
      parent.fetch("content", {}).fetch("relations", []).each do |version|
        # Make a link from parent vpid, we may have to use in search of AUDIO
        parent_link = "http://A-FUNNY-DOMAIN/content#{parent["content"]["id"]}"
        
        # IF the current entry has an externalID (vpid) simply print it out and its info to the HTML page
        if version["content"]["externalId"] and not entry_vpids.include? version["content"]["externalId"]
          entry_vpids.push( version["content"]["externalId"] )
          @index += 1
          printSingleNewsEntryInfoHTML( @index , parent["content"]["id"] , version )
        
        # Else if there is NO externalId and we haven't used the link before then we visit it to check external Trevor links for AUDIO vpids!
        elsif not version["content"]["externalId"] and not external_trevor_links.include? parent_link
          temp_hash = parseJSONFromLink( parent_link ) 
          
          # Store current link so we don't revisit the same TREVOR link multiple times
          external_trevor_links.push(parent_link)
          
          # This loop is for AUDIO since its stored differently in TREVOR
          temp_hash.fetch("relations", []).each do |audio_hash|
            # If its an audio vpid AND NOT a vpid we've stored AND duration > 0 (not a stream!) then grab it!
            if audio_hash["content"]["externalId"] and not entry_vpids.include? audio_hash["content"]["externalId"] and audio_hash["content"]["duration"] > 1
              entry_vpids.push( audio_hash["content"]["externalId"] )
              @index += 1
              printSingleNewsEntryInfoHTML( @index , parent["content"]["id"] , audio_hash )
            end
          end
        end
      end
    end
    @fileHtml.puts "</div>" # This div is to close all the News entries before moving onto iPlayer
  end  

#---------------------------------------------------------------------------------

  def printSingleNewsEntryInfoHTML( new_index , new_parent , new_version )
    puts "Vpid : #{new_version["content"]["externalId"]}"
    background_image = assignBackgroundImage( new_version["content"]["iChefUrl"] )
    @fileHtml.puts "<p>[#{new_index}]</p>"
    @fileHtml.puts "<ul>"
    @fileHtml.puts "<li class='caption'> #{new_version["content"]["caption"]}                                       </li>"
    @fileHtml.puts "<li><hr>                                                                                        </li>"
    @fileHtml.puts " <li class='news_vpid'>Vpid : #{new_version["content"]["externalId"]}                           </li>"
    @fileHtml.puts "<li><hr>                                                                                        </li>"
    @fileHtml.puts "<li class='news_type' >Type : #{new_version["content"]["type"].sub( "bbc.mobile.news." , "")}   </li>"
    @fileHtml.puts "<li class='news_embed'>Embeddable : #{new_version["content"]["isEmbeddable"]}                   </li>"
    @fileHtml.puts "<li class='news_durat'>Duration : #{new_version["content"]["duration"]/1000} secs               </li>"
    @fileHtml.puts "<li class='news_guide'>Guidance : #{new_version["content"]["guidance"]}</li>" if new_version["content"]["guidance"]
    @fileHtml.puts "<li><hr></li>"

    # Store stats for summary
    @news_stats["#{new_version["content"]["guidance"]}"] += 1
    @news_stats["Embeddable #{new_version["content"]["isEmbeddable"]}"] += 1

    # Create links + any flag
    createNewsArticleLink( new_parent )
    @fileHtml.puts "<li><hr></li>"

    if new_version["content"]["type"] == "bbc.mobile.news.audio"
      createCookBookLink(     "news" , background_image , new_version["content"]["caption"] , new_version["content"]["guidance"] , new_version["content"]["externalId"] , "radioProgramme" )
      createTestCookBookLink( "news" , background_image , new_version["content"]["caption"] , new_version["content"]["guidance"] , new_version["content"]["externalId"] , "radioProgramme" )
    else
      createCookBookLink(     "news" , background_image , new_version["content"]["caption"] , new_version["content"]["guidance"] , new_version["content"]["externalId"] , "programme" )
      createTestCookBookLink( "news" , background_image , new_version["content"]["caption"] , new_version["content"]["guidance"] , new_version["content"]["externalId"] , "programme" )
    end

    @fileHtml.puts "<li><hr></li>"
    @fileHtml.puts "<li class='news_audio_flag'>AUDIO</li>" if new_version["content"]["type"] == "bbc.mobile.news.audio"
    @fileHtml.puts "</ul></div>"
  end

  #---------------------------------------------------------------------------------

  def printIplayerVpidsFromLink( new_title , new_link , new_section , new_flag )
    iplayer_hash = parseJSONFromLink( new_link )
    printIplayerHeader( new_title )

    # Cycle through the iPlayer Hash of vpids
    iplayer_hash[new_section]["elements"].each do |parent|
      # If the link was a "category" or a "channel" the json structure is slightly different so we handle accordingly
      if new_section == "category_programmes" or new_section == "channel_programmes"
        parent["initial_children"].each do |child|
          child["versions"].each do |version|
            if (new_section == "category_programmes" and version["kind"] == new_flag) or new_section == "channel_programmes"
              printIplayerVpid( parent , version )
            end
          end
        end
        # Else if its "Most Popular" and not a particular channel or kind
      else
        if new_flag == "guidance"
          parent["versions"].each do |version|
            #  If we just want guidance content on "Most Popular"
            if parent["guidance"] == true
              printIplayerVpid( parent , version )
            end
          end
        else
          # We want all types of conetent on "Most Popular" regardless of guidance
          parent["versions"].each do |version|
            printIplayerVpid( parent, version )
          end
        end
      end
    end
  end

  #---------------------------------------------------------------------------------

  def printIplayerVpid( parent , version )
    temp_guidance = ""
    background_image = assignBackgroundImage( parent["images"]["standard"] ) 
    @fileHtml.puts "<p>[#{@index+=1}]</p>"
    @fileHtml.puts "<ul>"
    @fileHtml.puts "<li class='title'>#{parent["title"]}                                </li>"
    @fileHtml.puts "<li><hr>                                                            </li>"
    @fileHtml.puts " <li class='iplayer_vpid'>Vpid : #{version["id"]}                   </li>"
    @fileHtml.puts "<li><hr>                                                            </li>"
    @fileHtml.puts "<li class='iplayer_kind'>Kind : #{version["kind"]}                  </li>"
    @fileHtml.puts "<li class='iplayer_hd'>HD : #{version["hd"]}                        </li>"
    @fileHtml.puts "<li class='iplayer_downl'>Download : #{version["download"]}         </li>"
    @fileHtml.puts "<li class='iplayer_durat'>Duration : #{version["duration"]["text"]} </li>"

    # If it's "Most Popular" and has guidance
    if ! parent["initial_children"] and version["guidance"]
      @fileHtml.puts "<li class='iplayer_guide'>Guidance : #{parent["guidance"]}  </li>"
        if parent["guidance"] == true and version["guidance"]
        temp_guidance = version["guidance"]["text"]["medium"]
        @fileHtml.puts "<li>Guidance #{version["guidance"]["text"]["medium"]}  </li>"
      end
    end
    # "Channels" and "Categorys" have a slightly different JSON structure to "Most Popular"
    if parent["initial_children"]
      parent["initial_children"].each do |child_hash|
        child_hash.each do | key , value |
          if key == "guidance" and version["guidance"]
            if version["guidance"]
              @fileHtml.puts "<li class='iplayer_guide'>Guidance : #{value}</li>"
            end
            if value == true
              temp_guidance = version["guidance"]["text"]["medium"]
              @fileHtml.puts "<li class='iplayer_guide'>Guidance : #{version["guidance"]["text"]["medium"]}</li>"
            end
          end
        end
      end
    end
    @fileHtml.puts "<li><hr></li>"

    @iplayer_stats[version["kind"]] += 1 # Store stats for summary
    
    # Create links to iplayer pages + print any (SIGNED/AD) flag
    createIplayerLink( parent["id"] , version["kind"] )

    @fileHtml.puts "<li><hr></li>"
    createCookBookLink(     "iplayer" , background_image , parent["title"] , temp_guidance , version["id"] , "programme" )
    createTestCookBookLink( "iplayer" , background_image , parent["title"] , temp_guidance , version["id"] , "programme" )
    @fileHtml.puts "<li><hr></li>"
    createIplayerKindFlag( version["kind"] )
    @fileHtml.puts "</ul></div>"
  end

  #---------------------------------------------------------------------------------

end