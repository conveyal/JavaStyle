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

## Build System

Build with Maven (just because it's standard and provides zillions of libraries). Maven is very opinionated, and allows you to shoot yourself in the foot. Rather than trying to force it to behave in a certain way, follow its conventions as much as possible. Multi-module builds caused us all sorts of pain with OpenTripPlanner a few years back. Avoid multi-module builds, at least until we can research how they have evolved and matured since that time.

## Continuous integration

We use Travis CI to build every commit that is pushed to our Java repositories. We should document various things about this process, including deployment to Maven central, the fact that certain projects have builds uploaded to S3, our old Conveyal Maven repository.

## Performing a Release

Most of our Java projects use the Maven build and dependency management system. We do not use the `maven-release` plugin to perform releases. That plugin requires only non-SNAPSHOT dependencies. Also, we don't want to perform releases from our local machines and prefer to let Travis CI do them. It provides a consistent build environment and there is no risk of stray local commits getting into a release.

However, our manual release process closely mimics what `maven-release` does. Releases must be tagged with git *annotated* tags, not *lightweight* tags. This is because `git describe` references the last annotated tag, and we use git describe as a way of specifying and identifying analyst woker versions. For the R5 project, these annotated tags should systematically begin with the letter v because this is how our scripts recognize shaded JARs named with git describe output as opposed to un-shaded maven artifact JARs. For OpenTripPlanner, these tags should be of the form `otp-1.1.0`. 

Here is the typical release process:
```
[check that all dependencies are on non-SNAPSHOT versions]
[check on Travis that the build is currently passing]
[check that you have pulled all changes from origin]
[edit version in POM to 0.3.0]
git add pom.xml
git commit -m "Prepare 0.3.0 release"
git tag -a v0.3.0 -m "Release 0.3.0"
git push origin v0.3.0
[edit version in POM to 0.4.0-SNAPSHOT]
git add pom.xml
git commit -m "Prepare next development iteration 0.4.0-SNAPSHOT"
git push
```

The CI system will see the pushed commits, build them, and take appropriate steps to deploy the resulting artifacts to the staging repository. If the version number in the POM indicated that the commit is a release, the artifacts should be synced to Maven Central automatically. 

Note that the release must be tagged on the master branch, not a maintenance or feature branch. The maintenance branch for a particular release should be created *after* that release is tagged. This is because git-describe determines the version by tracing back through the history to the most recent tag. A tag on a non-master branch will never be seen.

