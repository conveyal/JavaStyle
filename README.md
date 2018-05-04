# Conveyal Java Code Style Guide

## General

This document contains points we have discussed and decided on within Conveyal. For any point that is not covered by this document, we defer to the Google Java style guide. https://google.github.io/styleguide/javaguide.html

Plase make incremental changes as you go along to bring old code in line with current code standards. However, you should separate those changes out into separate commits that only concern documentation or formatting, that should therefore be no-ops from the compiler's point of view. It is  easier to understand changes to functionality later when they are not mixed with changes to wrapping, brackets, comments etc.

### Do not use wildcard imports

Unfortunately, by default IntelliJ IDEA aggressively inserts wildcard imports automatically, for example: `import com.vividsolutions.jts.geom.*;`

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

In IntelliJ IDEA you can change default generated method bodies to have the behavior we want. Go to `Preferences -> Editor -> File and Code Templates -> Code tab -> Overridden Method Body`, and set it to `throw new UnsupportedOperationException();`.

### Never silently swallow exceptions

Java's checked exceptions are obnoxious. Frequently while prototyping and building up new code, you just want to let exceptions bubble all the way up and disrupt the application, but you don't want to add `throws VerySpecificCheckedException` to every one of your method signatures all the way up the call stack to the point where you have defined a generic facility for catching and logging unexpected or unhandled problems. Your IDE will auto-insert try-catch blocks, but they often do something close to silently swallowing exceptions: they just log the stack trace to the console and continue execution. In IntelliJ IDEA, you can change the default catch body to rethrow unchecked exceptions. Go to `Preferences -> Editor -> File and Code Templates -> Code tab -> Catch Body` and set it to `throw new RuntimeException(${EXCEPTION});`.

### Bubble complete exception information up to UIs

When bubbling Exceptions up to UIs, don’t use `exception.getMessage()`. For many exception types this doesn’t return anything useful. For example, for all NullPointerExceptions this will just return `null`. There are three pieces of information we need to facilitate debugging: the exception type, the detail message (if any), and the source code line where it happened (for all stack frames). The simplest thing to do is call `exception.toString()` which will at least get you the exception class and message. But ideally use something like our `ExceptionUtils.asString()` method in R5, which appends a stacktrace to the exception class and detail message.

### Units and Symbolic Constants

Always suffix the names of numeric variables with the units in which they are expressed. Always use symbolic constants for numbers included in expressions unless the source and meaning of the number is completely obvious. Numeric constants in Java can have underscores in them to group thousands. Use this for numbers over 1000. This makes it easier to visually sanity check the magnitude of the constant.

```
int distanceMillimeters = distanceMeters * 1000; // OK
int durationMinutes = durationHours * 60; // OK, but still could use a symbolic constant

public static final EARTH_CIRCUMFERENCE_METERS = 40_075_017;
public static final int METERS_PER_FURLONG = 201.168;
double distanceMeters = EARTH_CIRCUMFERENCE_METERS / METERS_PER_FURLONG; // The best way
```

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


## Comments

### Javadoc Comments

Every public method and public field should have a Javadoc comment. Comments should not be trivial, i.e. should not repeat information visible in the method name and parameter names and types. 

### In-line comments

Always imagine yourself reading a comment a year in the future when you've forgotten this module exists, or think about what it's like reading someone else's code when you have no understanding of that person's thought process. Over the long term, the vast majority of time spent on software is maintenance and operations. Someone will eventually need to reverse-engineer what you've written, and that someone may well be your future self who's completely forgotten this code. If you write the comments as you create the code, it also helps double-check your thinking to have "redundant" versions of the same logic side by side in prose and symbolic form.

So it's completely normal and even desirable to write code that's 50% comments!

Currently for in-line comments we use a mix of end-of-line comments beginning with a double-slash (`//`) and bracketed comments (`/* comment */`). We should settle on some standard for this.

