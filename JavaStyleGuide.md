# Conveyal Java Code Style Guide

Plase do make incremental changes as you go along to bring old code in line with current code standards. But also do separate those changes out into separate commits that only concern documentation or formatting, that should therefore have no impact on object code (are no-ops from the compiler's point of view).

## Comments

### Javadoc Comments

Every public method and public field should have a Javadoc comment. Comments should not be trivial, i.e. should not repeat information visible in the method name and parameter names and types. 

### In-line comments

Always imagine yourself reading a comment a year in the future when you've forgotten this module exists, or think about what it's like reading someone else's code when you have no understanding of that person's thought process. Over the long term, the vast majority of time spent on software is maintenance and operations. Someone will eventually need to reverse-engineer what you've written, and that someone may well be your future self who's completely forgotten this code. If you write the comments as you create the code, it also helps double-check your thinking to have "redundant" versions of the same logic side by side in prose and symbolic form.

So it's completely normal and even desirable to write code that's 50% comments!

Currently for in-line comments we use a mix of end-of-line comments beginning with a double-slash (`//`) and bracketed comments (`/* comment */`). We should settle on some standard for this.

