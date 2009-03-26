This "samples" directory contains both sample code and engineering
test cases.

SampleMap is a straightforward example of the Route-me library in
action, using the Open Street Map project's map tiles, and retrieving
data from their server. Developers: please don't check in any code
that breaks this project.

MapTestbed is similar to SampleMap, but is meant as a starting point
for writing test cases. Developers are encouraged to clone the
MapTestbed project when testing new features or when trying to
duplicate bugs. If you make changes to MapTestbed to exercise a new
Route-me features, please check in your revised version under a new
name.

ProgrammaticMap demonstrates creating a map without using a Nib.

MapTestbedTwoMaps shows two different map sources (Microsoft Virtual
Earth's hybrid view, and CloudMade's Tourist theme) in the same app.

MapTestbedFlipMaps shows two different kinds of marker tap/drag
response behavior, using two different RMMarker delegate classes.

SimpleMap is the old map example from Route-Me release 0.2, with
draggable markers and the Open Street Map source.
