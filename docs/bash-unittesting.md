# Bash project CI/CD integration

## Unit testing

[Bash Unit](https://github.com/bash-unit/bash_unit/tree/main) :

 - bash_unit allows you to write unit tests (functions starting with test), 
 - run them and, 
 - in case of failure, displays the stack trace with source file and line number indications to locate the problem.

### Install



This will install bash_unit in your current working directory:

```shell
curl -s https://raw.githubusercontent.com/bash-unit/bash_unit/master/install.sh | bash
```

## Rut tests

In terminal:

```shell
./bash_unit tests/*.sh
```