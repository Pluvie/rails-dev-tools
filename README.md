# Dev
This gem installs an executable command named `dev` which aims to help you develop and maintain Ruby or Ruby on Rails projects.

This gem takes inspiration from the Git Workflow published on [this page](https://nvie.com/posts/a-successful-git-branching-model/).

This gem can be used with mini Ruby projects composed of just one directory and a few files and at the same time with big Rails projects with many main apps and engines.

To work with big project, it is assumed that you organized your folders as follows:

```bash
/path/to/project/                     # Main project directory
/path/to/project/main_apps            # Main apps directory
/path/to/project/main_apps/app1       # Main app 1
/path/to/project/main_apps/app2       # Main app 2
...
/path/to/project/engines              # Engines directory
/path/to/project/engines/engine1      # Engine 1
/path/to/project/engines/engine2      # Engine 2
...
```

## Installation
Install with:
```bash
$ gem install rails-dev-tools
```

This will install an executable command named `dev`.

## Usage
From the shell run:
```
$ dev help
```

To list all the available commands.

## Commands

Usual git commands are `pull` and `push`. If you have a big project, this helps you pulling and pushing without moving from the current directory.

### Pull

To pull data for a specific main app or engine:

```bash
dev pull app1
dev pull engine2
```

To pull data for all main apps and engines:
```
dev pull
```

### Push

To push data for a specific main app or engine:

```bash
dev push app1 "commit message"
dev push engine2 "commit message"
```

### Feature

If you want to start developing a new feature:
```bash
dev feature open my-new-feat
```

You will be placed on a new branch called `feature/my-new-feat`. Do all your work and then push it. After that, you can close your feature with:
```bash
dev feature close my-new-feat
```

This will merge the feature branch on the `develop` branch.

### Release

When all your work into the develop branch is ready to become a new release, run:

```bash
dev release open 0.2.0
```

You will be placed on a new branch called `release/0.2.0`. You can work on this branch until it becomes stable and passes all tests. At this point commit and push your work and then run:
```
dev release close 0.2.0
```

This will merge the release branch on the `master` branch.

### Hotfix

If you need to quickly fix a bug that accidentally made it to production, run:
```bash
dev hotfix open 0.2.1
```

You will be placed on a new branch called `hotfix/0.2.1`. While on this branch, write only code that fixes the bug(s) found. Do not start new features or continue developing existing ones. When you have fixed the bug run:
```bash
dev hotfix close 0.2.1
```

This will merge the hotfix branch on the `master` branch and on the `develop` branch.

## License
The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
