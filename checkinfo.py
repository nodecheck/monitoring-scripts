#!/usr/bin/env python3
#
# NodeCheck checkinfo script

# Import the stuff we need to use
from sys import argv
from subprocess import check_output
from pkgutil import find_loader
from random import randint
import time

# User-defined variables
clitool = "/path/to/coin-cli|coindaemond"
apikey = "your-api-key-here"
payee = "your-mn-payee-here"
txid = "your-mn-txid-here"

# DO NOT EDIT BELOW THIS LINE!!!

# Check if user completed above user-defined variables
if clitool == "/path/to/coin-cli|coindaemond" or apikey == "your-api-key-here" or payee == "your-mn-payee-here" or txid == "your-mn-txid-here":
    print("One of the user-defined variables hasn't been configured!")
    print("Please check that: clitool, apikey, payee and txid have been")
    print("configured at the beginning of the script!")
    exit(1)

# Check python3-requests and python3-simplejson are installed
# Import or inform user of problems
if find_loader("requests"):
    import requests
else:
    print("Error: python3-requests is not installed!")
    print("Please install if you wish to use this script.")
    exit(1)

if find_loader("simplejson"):
    import simplejson as json
else:
    print("Error: python3-simplejson is not installed!")
    print("Please install if you wish to use this script.")
    exit(1)

# Define variables
prog_name = argv[0]
parms = ""
clisuffix = "cli"
waittime = randint(1, 600)
blocks = None
blockhash = None
success = None
headers = {'Content-type': 'application/json', 'User-Agent': 'NodeCheck API Script'}
url = "https://nodecheck.io/api/sendinfo"
results = None

# Check if we passed a parameter, and set it accordingly
if len(argv) > 1:
    parms = argv[1]

# Define functions to use
def getinfo(jsondata, item):
    getjsondata = check_output([clitool, jsondata])
    extractjsondata = json.loads(getjsondata)
    getjsonkey = extractjsondata.get(item)
    return getjsonkey

def getblockinfo(item, bhash=None):
    if bhash is None:
        getdata = check_output([clitool, item])
    else:
        getdata = check_output([clitool, item, bhash])
    decodedata = getdata.decode("utf-8")
    stripdata = decodedata.rstrip()
    return stripdata

# Collect the information we need: version, blocks, blockhash
if clitool.endswith(clisuffix):
    # We are using coin-cli command
    version = getinfo("getnetworkinfo", "subversion")
else:
    # We are using coindaemond command
    version = getinfo("getinfo", "version")

if "/" in version:
    version = version.replace("/", "")

blocks = getblockinfo("getblockcount")
blockhash = getblockinfo("getblockhash", blocks)

if parms == "--test":
    print("Test to verify if script is working.\n")
    print("Information being submitted:\n")
    print("MN/Wallet version: " + version)
    print("Blockheight:       " + blocks)
    print("Blockhash:         " + blockhash + "\n")
    data = {'access-token': apikey, 'payee': payee, 'txid': txid, 'version': version, 'blocks': blocks, 'blockhash': blockhash}
    results = requests.post(url, data=json.dumps(data), headers=headers)
    parsed = json.loads(results.text)
    success = parsed.get('success')
    if success:
        print("API Connection: OK " + str(results))
    else:
        print("Problem with API connection.")
        print("Error: FAILED " + str(results))
elif parms == "":
    # Send data to User's NodeCheck profile so that notifications can be sent
    # when a new wallet update is available and also to compare blocks and
    # blockhash
    time.sleep(waittime)
    data = {'access-token': apikey, 'payee': payee, 'txid': txid, 'version': version, 'blocks': blocks, 'blockhash': blockhash}
    results = requests.post(url, data=json.dumps(data), headers=headers)
else:
    print("Invalid parameter!")
    print("Valid parameters: --test or run script without any parameters!")
    exit(1)
