# *ps-config* #

## Screenshot ##
![Picture of my current console look and feel](http://i.imgur.com/YuyiD0M.png)

## Installation ##
One Liner (run this in powershell as the current user context):
```
pushd "$env:USERPROFILE\Documents"; git clone --recursive https://github.com/chrisbenti/ps-config.git WindowsPowerShell; . $PROFILE; popd
```

You will also need ConEmu with one of the patched fonts

## Testing ## 
Testing is done with the ![Pester](https://github.com/pester/Pester) framework.

To execute tests, run "test.bat" from your profile root.

## Inspiration and Resources ##
- [Oh-My-ZSH Theme](https://gist.github.com/agnoster/3712874)
- [Patched Fonts](https://gist.github.com/qrush/1595572)
