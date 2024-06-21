# dynamic_dns
Quick and Dirty Dynamic DNS Using GoDaddy and Cloudflare

# Cloudflare

Step 1 - Create API Token
    
    Edit Zone DNS - Use Template
![Alt text](images/Cloudflare-DDNS-1.png?raw=true "Cloudflare Dynamic DNS - DNS Key")

Step 2 - User API Tokens Settings
    
    Zone | Zone Settings | Read
    Zone | Zone | Read
    Zone | DNS | Edit

    Zone Resources
    Include | Specific Zone

A Record Proxy Status should be DNS only.
![Alt text](images/Cloudflare-DDNS-2.png?raw=true "Cloudflare Dynamic DNS - Zone Settings")
