# scribed launcher

* http://github.com/tagomoris/scribed_launcher

## DESCRIPTION

Init script (start-stop script) and misc for facebook scribed. You must install scribed on the other hand.

## INSTALL

First, build/install scribed, and clone repository, and do `make install`. Path of scribed is read when install launched.

## Run

Start/stop scribed with commands below.

    # /etc/init.d/scribed start
    # /etc/init.d/scribed restart
    # /etc/init.d/scribed stop

You can write configuraitons of scribed runtime, to /etc/scribed_launcher.conf.

## Configurations

### SCRIBED_PATH
* path of scribed
* default: /usr/local/bin/scribed (or detected path on install)

### CONFIG_FILE
* path of scribed configuration file
* default: /etc/scribed.conf

### USERNAME
* username lanches scribed
* default: root

### CLASSPATH
* CLASSPATH pattern for scribed process
* `scribed_admin` extracts file globs (such as: CLASSPATH=/usr/local/hadoop/lib/*.jar:/usr/local/hive/lib/*.jar)
* default: none

### LOGPATH
* log file path of scribed
* default: /var/log/scribed.log

### ROTATELOGS
* log output with rotatelogs
* if you want to use rotatelogs, set path of rotatelogs (such as: /usr/local/apache2/bin/rotatelogs)
* default: none (DO NOT USE rotatelogs)

### ROTATELOGS_ARGS
* arguments of rotatelogs
* see `man rotatelogs`
* default: 86400

* * * * *

## License

Copyright 2011 TAGOMORI Satoshi (tagomoris)

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

   http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
