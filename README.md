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
