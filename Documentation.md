# Documentation

SwiftUIX documentation is a work in progress, where types will be documented, articles written, etc.

This document explains how to work with and handle documentation in SwiftUIX.


## DocC

[DocC][DocC] is a documentation tool from Apple, that lets you produce rich API reference documentation and interactive tutorials for your Swift framework or package.

The DocC documentation compiler converts Markdown-based text into rich documentation for Swift frameworks and packages. You can preview the documentation in its published form as you work on it, and also host it on a website when it’s complete.

DocC documentation for SwiftUIX is generated from the types in the package, as well as from articles in the `SwiftUIX.doccarchive` archive.


## Current State - A Bit Broken

DocC was recently added to SwiftUIX, and focus has so far been to get the process up and running, and to integrate well with GitHub Actions.

Since SwiftUIX is HUGE and contains many types, we need to discuss how to best group types into namespaces or hide types from the top-level, using Swift annotations.

DocC also takes an *extremely* long time to generate, both from Xcode and from the Terminal. Since it's meant to be used as programmer reference, this is a critical problem that needs to be fixed.


## How to generate DocC documentation

You can generate DOcC from Xcode from `Product` > `Build Documentation`, or by running `fastlane docc` from the Terminal.


## GitHub Pages

The `.github/workflows/docc.yml` file defines how GitHub Actions should build and deploy documentation to GitHub Pages.

GitHub will by default build documentation when pushes are made to the `master`, but you can add more branches to the workflow file to let them trigger this workflow.

However, since GitHub has environment protection rules that limit which branches are allowed to build to GitHub Pages, you may see this error:

```
Branch "xxx" is not allowed to deploy to github-pages due to environment protection rules.
``` 

If so, you can adjust the `github-pages` rule in the SwiftUIX repository, under `Settings` > `Environments`. Just select the rule and add the branch you want to allow, and the new branch should be accepted.


[DocC]: https://www.swift.org/documentation/docc/
