# Heisenautomod

Heisenautomod is a simple automatic room moderator.

## Installation

Make sure you have the following installed:
- [Elixir](http://elixir-lang.com)
- [Git](https://git-scm.com/)

Open a terminal/cmd and execute the following commands:
The $ denotes that the following is a command you should enter in your terminal.
```
$ git clone https://github.com/dongmaster/heisenautomod
$ cd heisenautomod
$ mix deps.get
```

Next, navigate to the `config` directory and copy (the original file should still exist) the `config.exs.default` file to `config.exs`

Open the `config.exs` file in your favorite text editor and make whatever changes you want/need to make.

You're done with setting up the bot!

Let's start it!

Execute this command in the heisenautomod directory and the bot will start up.
```
$ iex -S mix
```


## Updating

Navigate to the `heisenautomod` directory and run the following command:
```
$ git pull origin master
```

Congrats, the bot has been updated.
