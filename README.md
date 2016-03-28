# JavaStyle
Java style guide for all Conveyal Java projects

### Do not use wildcard imports

IntelliJ IDEA adds wildcard imports automatically: 

```
import com.vividsolutions.jts.geom.*;```
```

This is causes namespace pollution and we'd prefer to import only the classes we want to use like so:

```
import com.vividsolutions.jts.geom.Coordinate;
import com.vividsolutions.jts.geom.Envelope;
import com.vividsolutions.jts.geom.Geometry;
import com.vividsolutions.jts.geom.LineString;
import com.vividsolutions.jts.geom.Point;
```

In IntelliJ, go to `Editor -> Code Style -> Java` and on the `Imports` tab set "Class count to use import with '*'" to 9999 or so. Amazingly there's no way to turn off this feature that goes against most received wisdom.

### Throw exceptions or log warnings for unsupported functionality

We like to move fast and build working prototypes. Functionality is often omitted in the interest of carrying out a demonstration or a specific case study on a deadline. When you consciously choose to implement only one code path out of several (*e.g.* considering GTFS calendar dates but not simple calendars because you know your input data contains only the former) always create stubs for the missing functionality which either throw an exception or log at WARN or ERROR level when those code paths are taken. It is all too easy to forget that a particular function is only half-implemented, turning a conscious simplification into a strange bug.
