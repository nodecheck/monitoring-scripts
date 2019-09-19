#!/bin/bash
#
#######################################
# Copyright: 2018-2019 - Nodecheck.io #
# Version: 1.1                        #
#######################################

######################################################################
# Script to check and verify wallet version for NodeCheck.io MN      #
# Monitoring Platform. This will then allow for providing            #
# notifications when a new wallet is available for the MN you are    #
# monitoring.                                                        #
######################################################################
RUNMODE=$1

######################################################################
# The following four variables need to be set:                       #
#                                                                    #
# 1. Replace CLITOOL with path to cli tool. An example is listed.    #
# 2. Add your API KEY from NodeCheck website.                        #
# 3. Add TXID of your masternode (from MN config file).              #
# 4. Add payee/pubkey of your masternode (from MN config file).      #
# 5. If running more than one coin on your node, change output to    #
# eg: /tmp/checkinfo-coin1.json                                      #
######################################################################
CLITOOL=/path/to/coin-cli|coindaemond
APIKEY=<your-api-key-here>
TXID=<your-mn-txid-here>
PAYEE=<your-mn-payee-here>
OUTPUT=/tmp/checkinfo.json

############################
# Info to check and update #
############################
# Get version, blocks, and blockhash
if [[ $CLITOOL == *"-cli" ]]
then
  # Coin uses coin-cli command
  VER=`$CLITOOL getnetworkinfo | grep subversion | cut -f4 -d "\""`
  # Remove / character from version info
  VERSION=`echo $VER | sed 's/\///g'`
else
  # Coin uses coind daemon command
  VER=`$CLITOOL getinfo | grep version | egrep -iv "protocol|wallet" | cut -f2 -d ":" | sed 's/,//' | sed 's/"//g'`
  # Remove / character from version info
  VERSION=`echo $VER | sed 's/\///g'`
fi

BLOCKS=`$CLITOOL getblockcount`
BLOCKHASH=`$CLITOOL getblockhash $BLOCKS`

#####################################################################
# Update users' MN info on NodeCheck.io using API to update:        #
# VERSION/BLOCKS/BLOCKHASH                                          #
#####################################################################
# Send output to file
echo "{\"access-token\":\"$APIKEY\", \"payee\":\"$PAYEE\", \"txid\":\"$TXID\", \"version\":\"$VERSION\", \"blocks\":\"$BLOCKS\", \"blockhash\":\"$BLOCKHASH\"}" > $OUTPUT

# Check how we ran script
# If no parameter passed, then run normally
if [ -z "$RUNMODE" ]
then
  # Update user's MN info no NodeCheck
  sleep $[ ( $RANDOM % 600 ) ]
  RESULTS=`curl -s -d @$OUTPUT -H "Content-Type: application/json" https://nodecheck.io/api/sendinfo`
  # Check if successful or not and display error
  if [[ $RESULTS == *"\"success\":true"* ]]
  then
    # All working OK
    exit 0
  else
    # There seems to be a problem!
    echo "Error: $RESULTS"
    exit 1
  fi
else
  # Check if we used --test parameter
  if [ $RUNMODE == "--test" ]
  then
    # Display test results to verify script configuration
    echo "Test to verify if script is working."
    echo ""
    echo "Information being submitted:"
    echo ""
    echo "MN/Wallet Version=$VERSION"
    echo "Blockheight=$BLOCKS"
    echo "Blockhash=$BLOCKHASH"
    RESULTS=`curl -s -d @$OUTPUT -H "Content-Type: application/json" https://nodecheck.io/api/sendinfo`
    # Check if successful or not and display error
    if [[ $RESULTS == *"\"success\":true"* ]]
    then
      # All working OK
      echo "API Connection OK."
      exit 0
    else
      # There seems to be a problem!
      echo "Problem with API connection."
      echo "Error: $RESULTS"
      exit 1
    fi
  else
    # Wrong parameter provided, display help information
    echo "Incorrect parameter provided to script."
    echo ""
    echo "Usage: checkinfo.sh [--test]"
    echo ""
    exit 1
  fi
fi
