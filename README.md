## NodeCheck Monitoring script

**For Linux MN/wallets only!**

NodeCheck have created a script to supplement the main NodeCheck service to offer extended functionality.  By utilising the NodeCheck Monitoring script on your masternode, you have the ability to:

1. Check/verify your current MN/wallet version, provide visibility of this under "My Nodes", and receive notifications when new MN/wallet versions are available.

2. Check/verify your current block height with our blockchains. ```*** coming soon ***```

3. Check/verify your blockhash with our blockchains. ```*** coming soon ***```

### What does NodeCheck Monitoring script do?

NodeCheck Monitoring script utilises the standard CLI RPC tools available to provide your MN/wallet version, current blockheight and blockhash for comparison with our platform.  This then enables the ability to check if:

1. Your MN/wallet is up-to-date.
2. Your blockheight is the same or within a similar range to ours.
3. Your blockhash for the submitted blockheight matches our blockchain.

```Please note, the script only collects version, blockheight and blockhash.  It does not collect any personal information from your node whatsoever, nor does it interrupt with the operation of your node.  The script is fully viewable on our github, and fully commented explaining exactly what each command in the script does, and the information it collects.  You can check/verify manually each of the commands we utilise in the script if you wish before use.```

### What happens when I run the script and provide this information?

The information is submitted and stored against the node you have registered in our system for monitoring purposes.  Then:

1. The version can be compared with ours, your version viewable under "My Nodes" on our site, and provide upgrade notification* for your MN/wallet when you are running an older version than us.
2. The blockheight is the same or within a similar range to ours.  If we notice that your blockheight doesn't change within a number of submissions, we can then notify* you that your node seems to have a stuck block.
3. The blockhash for your current blockheight matches ours for the same blockheight.  This can help potentially detect if you have forked, or if we have forked from the correct chain.

```* notifications provided for nodes with PRO functionality enabled.```

### Installation

Please make sure you have curl installed on your system as this is a requirement for the script to work:

```
apt install curl
```

Download our script:

```
curl -O https://raw.githubusercontent.com/nodecheck/monitoring-scripts/master/checkinfo.sh
```

As root user, move the file to /usr/local/bin and set the permissions so that it can be executed (this is so that the sript can be found and ran without providing the full path to the script):

```
mv checkinfo.sh /usr/local/bin/
chmod +x /usr/local/bin/checkinfo.sh
```

Generate your API key by going to https://nodecheck.io and click My Profile --> Preferences.  Part way down is "API access token".  Click the button below to generate an API key.  Each click will generate a new key, so if you think your key has been compromised, it's possible to generate a new one, and copy the key and paste into the monitoring script.

Edit and provide the following information for the script to run - edit the appropriate values within the script:

```
CLITOOL=
APIKEY=
TXID=
PAYEE=
OUTPUT=/tmp/checkinfo.json
```

The CLITOOL needs to be the path to the CLI RPC program on your node.  This could be, for example ```coinname-cli```, and therefore will need to contain the full path to wherever you have this located on your VPS.  Some coins don't have a separate CLI program, so in this instance you will substitute the command with the ```coindaemond``` name.

The APIKEY field, is your API key to connect to our site - you can find this under your profile preferences on our website.  The TXID and PAYEE are the two pieces of information to identify your node.  The payee is either payee/pubkey/collateral address that you used to send the coins for starting your node.  The TXID address is the long number related to the transaction you made when starting your node (usually with -0 or -1 at the end of it).  The TXID needs to be provided WITHOUT the -0 or -1 ending.

If you are running multiple coins on one VPS, please change ```OUTPUT=``` line so that it says something like:

```
OUTPUT=/tmp/checkinfo-coin1.json
```

and make sure that it uses a different file for each coin.  If you only have one MN running on your node, then you don't need to worry about changing this.

After the script has been edited and saved, we then need to run the script with the ```--test``` parameter to ensure that we have the correct location to CLI, correct API, correct TXID and correct PAYEE.  Also note, the script has to been run as the SAME user that the main daemon on your system runs as.  So, for example, if you run coinnamed as ```root```, then we need to run this script as root.  If you created a user on your system, for example: ```coinuser```, then we need to run the script as ```coinuser```.  This can be done by checking what user the daemon runs as:

```
ps aux | grep coinnamed | grep -v grep
```

you will then see one line return in the results, and the very first value is the user your daemon is running as.

Once we then have the user that the script is being ran as:

```
sudo -H -u user checkinfo.sh --test
```

replace ```user``` with the username you run the daemon as.  If the results show your current MN/wallet version, blockheight and blockhash, this means the script is working fine.

Now verify that no errors appear when sending the info to us:

```
sudo -H -u user checkinfo.sh
```

and wait for it to return to the console prompt.  If you get any errors, please check and correct the APIKEY, TXID or Payee.

Once all this has been done, we can now configure crontab to run the script hourly:

```
crontab -e -u user
```

replace ```user``` with the username you run the daemon as.  The crontab configuration should be as follows:

```
0 * * * *     /usr/local/bin/checkinfo.sh
```

this will run the monitoring script every one hour to check and update the information to monitor version, blockheight and blockhash.

### What if I run more than one wallet of varying coins on the same VPS?

No problem.  Change the name of the script, and copy to a new name, and provide the appropriate details in the next script.  For example:

```
cp checkinfo.sh /usr/local/bin/checkinfo-coin1.sh
cp checkinfo.sh /usr/local/bin/checkinfo-coin2.sh
cp checkinfo.sh /usr/local/bin/checkinfo-coin3.sh
```

replace coin1|coin2|coin3 with the coin you are running an MN for, then edit each of these three scripts, and then create the appropriate crontab for each script as per the above instructions.

### Can I run the script more frequent than every one hour?

No.  We are limiting the amount of connections to our server.  Technically you could change it, but we will just reject your connection attempt and potentially ban your IP for misuse of the service.  Therefore we recommend you leave the cron configuration EXACTLY to run every one hour.

### What if I don't want to provide this information?

No problem, you do not need to run the script at all.  However, we will not be able to provide you with MN/wallet upgrade notification*, nor will we be able to potentially notify you of stuck blocks, or blockhash mismatch/potential fork from original blockchain.

```* notifications provided for nodes with PRO functionality enabled.```

### How do I uninstall the script?

Very simple.  First edit the crontab and remove the line that was added during installation.  Second, delete the script that you downloaded from your system, so that it no longer exists on your node.

### Help and Assistance?

* Check our FAQ - https://nodecheck.io/site/faq
* Support on our Discord - https://discordapp.com/invite/3VV5GkG

### Disclaimer

NodeCheck will not be held responsible for misuse of this script or any adverse affects.  The script is provided as-is, and works perfectly fine when being utilised in the correct manner intended when following the instructions correctly.  If you are unsure, please contact us for assistance.
