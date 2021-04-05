# haproxy-testing
The purpose of this project is to demonstrate the viability of using HAProxy and Lua to forward pixel tracking events from a proxy to an event collection endpoint.  There are several components to this repo that allow for the containerized proxy with event forwarding code to be setup, as well as python code that generates and executes a configurable amount of requests.

## HAProxy And Lua
Lua is a scripting language that comes embedded in many HAProxy releases, and allows the functionality to be extended through custom scripts.  The purpose of this project is simply to show that the goal of forwarding a request through HAProxy to another endpoint can be accomplished, with the same result, using HA Proxy alone, as well as HAProxy in combination with Lua.  This is not meant to test performance, nor accommodate large scale testing.

## Usage
#### Prerequisites
1. Docker
2. Python3
3. Loggly Client Token
#### Setup
In order to forward events to the correct endpoint, a Loggly Client Token is required.  This can be obtained through the Loggly Web Portal, or from an admin with the token via secure transfer method, I.e. Keybase.  This token should be stored in a `.env`file in the format, `LOGGLY_TOKEN=<Client Token>`, and placed at the root of the project directory.

### HAProxy Routing Method Configuration - IMPORTANT
As mentioned above, the goal of this project is to test both the viability and effectiveness of using both HAProxy alone and HAProxy+Lua to facilitate event forwarding.  For simplicity, both the HAProxy and HAProxy+Lua approaches are written in the `haproxy.cfg`with one being commented out.  The HAProxy approach requires 2 lines in the `frontend` definition and one line in the `backend` definition, while the HAProxy+Lua method requires a single line in the `frontend` definition.  If all lines are left uncommented, the event should be sent in HAProxy mode.

### HAProxy Container
Once the `.env` file with the client token has been created in the project's root directory and the desired HAProxy method has been configured in the `haproxy.cfg` file, with Docker installed, navigate to the project's root directory in the terminal and run the following command:
```bash
docker-compose build && docker-compose up -d
```
A Docker container will spin up listening at localhost.  Localhost can now be cURLed or opened in a browser, or otherwise have requests sent to it to register an event that will show up in your account's Loggly logs.



### Python
For larger scale testing, a Python script has been created that leverages Faker to generate mock events including sample User-Agents, X-Forwarded-For, and Referer headers, webpage and event type, and shopping cart data.  This tool can either be used to generate sample cURL commands, or execute the requests directly once the HAProxy Container is running. <br>
To use this automated testing script, with python3 installed, navigate to `haproxy-testing/testing/python/` and run the following command:
```bash
pip install -r requirements.txt
```
This will install the necessary Python dependencies.  You're now ready to start running tests! <br>
#### `generate_events.py`
`args`:
| **arg** | **flag** | **choices** | **description** |
| --- | --- | --- | --- |
| `number` | -n/--number | N/A | Integer signifying the number of requests to generate |
| `test_batch` | -t/--test | N/A | Testing batch tag for Loggly searches |
| `curl` | -c/--curl | True, False | Flag to print cURL statements instead of executing requests |
`number` - The number of requests to generate.  The client, pixel, and campaign ids come from a predefined set of combinations, while everything else is largely generated at random.  **NOTE:** This was not meant to be a high-volume testing tool, merely to generate some realistic mock data, so the requests are not parallelized at all, meaning the request execution process is pretty slow.  I'd aim to keep batch sizes <=1000 if I were you. <br>

`test_batch` - This allows for an additional field, `testBatch`to be appended to the url query that will be set to the command line argument passed in.  If "my-test-batch" were passed to this argument, that value could then be searched in Loggly to see all events associated with that batch of requests. <br>

`curl` - This flag allows the generated requests to be printed as cURL commands that could be copied or exported to a file. <br>

Examples:

Generating a single request:
```bash
python generate_events.py -n 1
```

Generating 50 events with a testing batch label of "TheGreatestTestEver":
```bash
python generate_events.py -n 50 -t TheGreatestTestEver
```

Generating 22 cURL statements to be printed:
```bash
python generate_events.py -n 22 -c True
```


## Disclaimer
This was purely just a test HAProxy and Lua, and see if one gave more/easier access to headers and request information.  So in short, the Lua is likely not efficient, and the haproxy.cfg probably isn't optimal.  Also, the same encode function is in a file and imported.  I was having some issues with the imports.
