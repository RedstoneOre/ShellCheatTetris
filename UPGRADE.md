# Upgrading
> Sorry that we cannot upgrade your save by the program NOW!
# N.5 -> N.6(Normal Format)
> The Developer suggest you use vim
### From(copy @Info):
```sh
#! (Game Path)
@Info
```
### To(paste @Info):
```sh
#! /bin/python3
import subprocess
import os
PathStr=(Game Path:in single quotation marks)
subprocess.call([PathStr, os.path.realpath(__file__)])
'''
@Info
'''
```

