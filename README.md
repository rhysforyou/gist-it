# Gist It

Quickly and easily post the contents of the current editor to GitHub Gists. Just
type ⌥⌘G, type in a description and hit return, the Gist will be uploaded and
its URL will be copied to your system clipboard.

![](https://raw.github.com/rpowelll/gist-it/master/media/screencast.gif)

## Using Your GitHub Account

Gist It will post gists anonymously by default, to post to your own GitHub
account [generate a new token](https://github.com/settings/tokens/new) with the
`gists` scope and copy it into the package's preferences.

## Commands

- **Gist Current File (⌥⌘G)** Gists the contents of the current file in the editor

- **Gist Selection (⇧⌥⌘G)** Gists the contents of the current selection. If more
  than one selection is active, uses the most recent one.

- **Gist Open Buffers** Creates a gist with the content of all buffers in the active
  workspace

## Preferences

From the package's page in Atom's settings, you can set a few preferences:

- **New Gists Default To Private (Boolean)** By default, new gists will be
  _public_. you can change this option manually when creating the gist, or
  set it to instead default to _private_ by enabling this option.

- **User Token (String)** This field allows the user to enter a custom generated
  OAuth token to have Gists attributed to their GitHub account. A token can be
  created [here](https://github.com/settings/tokens/new) and must include the
  `gist` scope.
