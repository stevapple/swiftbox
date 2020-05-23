# Contribution Guide

## Design Guideline and Pull Requests

This project follows the following design guidelines, which will continue until the next breaking change of the Swift toolchain or itself.

If you'd like to contribute to the project by implementing a new feature or fixing bugs, make sure your code and API matches them.

- **Single-file and lightweight.** Keep it a single-file executable which can be easily installed or use as a script without any config.
- **Specific for platforms excluding macOS.** Apple has already provided a bunch of great Swift tools like `xcrun` on macOS and sometimes Darwin behaves differently from Linux, making Darwin support hard but quite useless.
- **Unaffected by unmanaged environment variables,** which is likely to differ between shells on the same system. The users are assumed to be totally ignorant about environment variables.
- **Keeping different defaults of system-wide, user-wide and project-wide**(coming at the next version). This allows `sudoer`s to install and configure Swift for its users.
- **Independent of any self-hosted APIs.** Use only official websites and repositories to retrieve package information and the toolchain.
- **Avoiding hard-coded information** like versions. This generally gives the program longer usability, while it can be discussed in specific cases.

If you're going to add a new feature or make breaking changes, **you're suggested to make a proposal by creating an issue before starting your implementation**, so that we can discuss about it in advance, making sure your idea is fit for the project.

## Commits and Pull Requests Naming Guide

`swiftbox` follows an easy naming guide, which simply contains two rules:

- Use **a verb phrase or a noun phrase** that describes what this commit or PR has done, and **start with upper case**.
- If there's more than one, remember to concat them like: one, two and three.

Here are some suggested verbs to use:

- Fix: Always use `Fix` when you fixes a bug; Alternatively, you can use the noun form.
- Add: Always use `Add` when you add a new file or a project-related feature; Sometimes, you can omit `Add` to make the message a nown.
- Support: Always use `Support` when you add a new subcommand or feature to the main program.
- Improve: You are suggested to use `Improve` when you refine the working process of any subcommand or module.

## API Naming Guide

`swiftbox` currently provides an unstable cli. When you design a new API, you simply need to:

- **Use a verb** instead of a noun (The `version` command is a counter-example which I'm going to refine).
- Use a simple verb, and **imagine you're doing this with a magic box**.

## Coding Style

Commits of pull requests will be asked to follow the coding (including naming, indentation and line-break) style of the original project. Here're some instructions:

- Use `verb-noun` styled function names, or `is-predicative` ones if the return value is used as a bool result.
- Use `OBJECT` or `ATTRIBUTE_OBJECT` styled variable names.
- Keep variables `local` if possible.

## About Operating System Supports

This project is **temporarily** dedicated to officially supported operating systems excluding macOS. If you want to configure it for another platform, welcome to fork as a new one.

Once Swift.org releases installation packages for other distributions, you can support them by creating pull requests. 