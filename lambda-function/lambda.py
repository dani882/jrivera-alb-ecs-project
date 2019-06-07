from __future__ import with_statement, print_function
from botocore.vendored import requests
from botocore.vendored.requests.adapters import HTTPAdapter
 
import cfnresponse
import json
 
RETRIES = 15
# For production it is advised to mirror this file on your own webserver.
TLD_DAT_URL = 'http://mxr.mozilla.org/mozilla/source/netwerk/dns/src/effective_tld_names.dat?raw=1'
 
# Attempt to fetch tld file from url
session = requests.Session()
session.mount('https://', HTTPAdapter(max_retries=RETRIES))
resp = session.get(TLD_DAT_URL)
resp.raise_for_status()
 
# Read file and strip out comments
tld_file = resp.text.splitlines()
tlds = [line.strip() for line in tld_file if not line.startswith("//")]
 
# The python lambda runtime is very barebones which requires the function
# to have code to perform the lookup instead of using a python module.
#
# Borrowed from https://stackoverflow.com/a/1069780/384973
def get_tld(url, tlds):
  url_elements = url.split('.')
 
  for i in range(-len(url_elements), 0):
    last_i_elements = url_elements[i:]
 
    candidate = ".".join(last_i_elements)
    wildcard_candidate = ".".join(["*"] + last_i_elements[1:])
    exception_candidate = "!" + candidate
 
    # match tlds:
    if (exception_candidate in tlds):
      return ".".join(url_elements[i:])
    if (candidate in tlds or wildcard_candidate in tlds):
      return ".".join(url_elements[i - 1:])
  raise ValueError("Domain not in global list of TLDs")
 
 
def lambda_handler(event, context):
  print("event: {}".format(json.dumps(event)))
  sans = event.get('ResourceProperties', {}).get('SANS', [])
 
  validation_options = []
  for san in sans:
    validation_option = {
      "DomainName": san,
      "ValidationDomain": get_tld(san, tlds)
    }
    validation_options.append(validation_option)
 
  print("options: {}".format(json.dumps(validation_options)))
  responseData = {}
  responseData['payload'] = validation_options
  cfnresponse.send(event, context, cfnresponse.SUCCESS, responseData)