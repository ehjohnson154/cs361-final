require_relative 'gis.rb'
require 'json'
require 'test/unit'

class TestGis < Test::Unit::TestCase

  def test_waypoint 
    waypoint1 = Waypoint.new(-121.5, 45.5, 30, "home", "flag")
    expected = JSON.parse('{"type": "Feature","properties": {"title": "home","icon": "flag"},"geometry": {"type": "Point","coordinates": [-121.5,45.5,30]}}')
    result = JSON.parse(waypoint1.get_waypoint_json)
    assert_equal(result, expected)

    waypoint2 = Waypoint.new(-121.5, 45.5, nil, nil, "flag")
    expected = JSON.parse('{"type": "Feature","properties": {"icon": "flag"},"geometry": {"type": "Point","coordinates": [-121.5,45.5]}}')
    result = JSON.parse(waypoint2.get_waypoint_json)
    assert_equal(result, expected)

    waypoint3 = Waypoint.new(-121.5, 45.5, nil, "store", nil)
    expected = JSON.parse('{"type": "Feature","properties": {"title": "store"},"geometry": {"type": "Point","coordinates": [-121.5,45.5]}}')
    result = JSON.parse(waypoint3.get_waypoint_json)
    assert_equal(result, expected)
  end

  def test_track 
    segment1 = TrackSegment.new([ Waypoint.new(-122, 45), Waypoint.new(-122, 46),Waypoint.new(-121, 46)])
    segment2= TrackSegment.new([Waypoint.new(-121, 45), Waypoint.new(-121, 46)])

    track1 = Track.new([segment1, segment2], "track 1")
    expected = JSON.parse('{"type": "Feature", "properties": {"title": "track 1"},"geometry": {"type": "MultiLineString","coordinates": [[[-122,45],[-122,46],[-121,46]],[[-121,45],[-121,46]]]}}')
    result = JSON.parse(track1.get_track_json)
    assert_equal(expected, result)

  end

  def test_world 
    home = Waypoint.new(-121.5, 45.5, 30, "home", "flag")
    store = Waypoint.new(-121.5, 45.6, nil, "store", "dot") 
  
    segment1 = TrackSegment.new([ Waypoint.new(-122, 45), Waypoint.new(-122, 46),Waypoint.new(-121, 46)])
    segment2= TrackSegment.new([Waypoint.new(-121, 45), Waypoint.new(-121, 46)])
    segment3 = TrackSegment.new([Waypoint.new(-121, 45.5), Waypoint.new(-122, 45.5) ])
  
    track1 = Track.new([segment1, segment2], "track 1") 
    track2 = Track.new([segment3], "track 2") 
  
    world = World.new("My Data", [home, store, track1, track2]) #creates world out of waypoints, and tracks

    expected = JSON.parse('{"type": "FeatureCollection","features": [{"type": "Feature","properties": {"title": "home","icon": "flag"},"geometry": {"type": "Point","coordinates": [-121.5,45.5,30]}},{"type": "Feature","properties": {"title": "store","icon": "dot"},"geometry": {"type": "Point","coordinates": [-121.5,45.6]}},{"type": "Feature", "properties": {"title": "track 1"},"geometry": {"type": "MultiLineString","coordinates": [[[-122,45],[-122,46],[-121,46]],[[-121,45],[-121,46]]]}},{"type": "Feature", "properties": {"title": "track 2"},"geometry": {"type": "MultiLineString","coordinates": [[[-121,45.5],[-122,45.5]]]}}]}')
    result = JSON.parse(world.to_geojson)
    assert_equal(expected, result)
  end

end
