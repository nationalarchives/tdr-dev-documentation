# Configure Signed Commits

[Signed Commits](https://docs.github.com/en/github/authenticating-to-github/managing-commit-signature-verification/signing-commits) are used to help to protect against supply chain & impersonation attacks by ensuring Git commits are verified as genuine through the use of GPG keys. 

An alternative setup guide is [here](https://withblue.ink/2020/05/17/how-and-why-to-sign-git-commits.html).

## Local Configuration
Install a GPG Client:

A GPG Client needs to be installed on your development machine. For Windows this can be [GPG4Win](https://www.gpg4win.org/). For MacOS, Use [Homebrew](https://brew.sh/): `brew install gpg`. For Linux, you probably have GPG installed out of the box, but if not GPG packages should be easily obtainable via your package manager of choice.

Generate a key via the command line terminal:
`gpg --gen-key`
Use the options:

Type: `(4) RSA (sign only)`

Keysize: `4096`

Expiration: You can start with `2y` for 2 years, or a longer/shorter period if you'd prefer. It can be renewed or revoked as required.

You'll also be asked for your full name, email address (use the address associated with your GitHub account), and a passphrase, which you will need whenever you commit unless using GPG tools that store your passphrase. 

You'll need your KeyID, which has the format 'rsa4096/xxxxxxxx' where 'xxxxxxxx' is a hexadecimal pattern. You can get this through the command:

`gpg --list-secret-keys`

Configure your own git client to use the key:

`git config --global user.signingkey <keyID>`

You can configure Git to sign all of your commits automatically:

`git config --global commit.gpgsign true`

Otherwise, whenever you commit you need to use the -S flag, e.g.:

`git commit -a -S`

## GitHub Configuration
You'll need the PGP block for your key, which you can obtain through:

`gpg --armor --export <keyID>`

Next log on to GitHub via the web site, then go to your account settings > SSH and GPG Keys > New GPG key.

Paste in the PGP block and save.

### Testing Configuration 
You can test that you've been successful by making a commit (remember to use the -S flag if you haven't configured your Git client to sign all commits) and pushing it to a repo (it can be a personal repo if you wish). You should see a 'verified' label through the GitHub web interface for your push.

![](./images/verified-commit.png)
