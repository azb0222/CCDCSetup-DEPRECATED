1) Create security group allowing for SSH into the connection_machines rather than having them all be in a public subnet 
2) all key files should be uploaded to s3 bucket rather than stored locally 

3) for some reason everyone can connect to the postgres database despite typing in password wrong -> harden this 

4) create two seperate namesapces for gitlabredist and postgressql in k8 deployment 


5) https://www.youtube.com/watch?v=J0ErkLo2b1E need to setup postgres HA, not just Postgres 