#!/usr/bin/env ruby

class Track
  def initialize(segments, name=nil)
    @name = name
    @segments = segments
  end

  def get_track_json() #returns a string of all the waypoint data in the track segments.
    j = '{'
    j += '"type": "Feature", '
    if @name != nil
      j+= '"properties": {'
      j += '"title": "' + @name + '"'
      j += '},'
    end
    j += '"geometry": {'
    j += '"type": "MultiLineString",'
    j +='"coordinates": ['
    # Loop through all the segment objects
    @segments.each_with_index do |s, index|
      if index > 0
        j += ","
      end
      j += '['
      # Loop through all the coordinates in the segment
      tsj = ''
      s.coordinates.each do |c|
        if tsj != ''
          tsj += ','
        end
        # Add the coordinate
        tsj += '['
        tsj += "#{c.lon},#{c.lat}"
        if c.ele != nil
          tsj += ",#{c.ele}"
        end
        tsj += ']'
      end
      j+=tsj
      j+=']'
    end
    j + ']}}'
  end
end

class TrackSegment 
  attr_reader :coordinates
  def initialize(coordinates)
    @coordinates = coordinates
  end
end

class Waypoint
attr_reader :lat, :lon, :ele, :name, :type
  def initialize(lon, lat, ele=nil, name=nil, type=nil)
    @lat = lat
    @lon = lon
    @ele = ele
    @name = name
    @type = type
  end

  def get_waypoint_json(indent=0) #returns a string of the waypoint info
    j = '{"type": "Feature",'
    j += '"geometry": {"type": "Point","coordinates": '
    j += "[#{@lon},#{@lat}"
    if ele != nil
      j += ",#{@ele}"
    end
    j += ']},'
    if name != nil or type != nil
      j += '"properties": {'
      if name != nil
        j += '"title": "' + @name + '"'
      end
      if type != nil  
        if name != nil
          j += ','
        end
        j += '"icon": "' + @type + '"'  
      end
      j += '}'
    end
    j += "}"
    return j
  end
end

class World
def initialize(name, features)
  @name = name
  @features = features
end

  def add_feature(feature)
    @features.append(feature)
  end

  def to_geojson(indent=0) #prints  all the features of the world
    s = '{"type": "FeatureCollection","features": ['
    @features.each_with_index do |f,i|
      if i != 0
        s +=","
      end
        if f.class == Track
            s += f.get_track_json
        elsif f.class == Waypoint
            s += f.get_waypoint_json
      end
    end
    s + "]}"
  end
end

def main()
  #create waypoint flags
  home = Waypoint.new(-121.5, 45.5, 30, "home", "flag")
  store = Waypoint.new(-121.5, 45.6, nil, "store", "dot") 

  #create tracks
  segment1 = TrackSegment.new([ Waypoint.new(-122, 45), Waypoint.new(-122, 46),Waypoint.new(-121, 46)])
  segment2= TrackSegment.new([Waypoint.new(-121, 45), Waypoint.new(-121, 46)])
  segment3 = TrackSegment.new([Waypoint.new(-121, 45.5), Waypoint.new(-122, 45.5) ])

  track1 = Track.new([segment1, segment2], "track 1") 
  track2 = Track.new([segment3], "track 2") 

  #create world
  world = World.new("My Data", [home, store, track1, track2]) 
  puts world.to_geojson()
end

if File.identical?(__FILE__, $0)
  main()
end

