 1. ssh into device for the first time
 1. accept keys
 1. log out or switch to new tab. (ctrl + t)
 1. type config
 1. go to hosts
 1. add new hosts
 1. give host an alias 
 1. under hostname type either the hostname or ip address
 1. change port if not using default ssh ort
 1. enter user name
 1. leave password blank
 1. click save
 1. test by typing ssh alias (alias being the alias you gave the host in step 7)
 1. you should be asked to enter your password

# Add keys

1. in blink prompt, type config
1. select keys
1. if you have secure enclave option continue, else go to step X
1. select ecdsa
1. input a key name
1. add commention (optional)
1. click create
1. go to settings
1. select hosts
1. select the host you want to send the key to
1. select save
1. at the blink prompt type 'ssh-copy-id keyname host-alias
1. press enter
1. you may need to hit enter again
1. type yes
1. enter password again
1. if you are logged into the host type exit
1. from the blink prompt, type 'ssh host-alias you should log into the host without needing your password


