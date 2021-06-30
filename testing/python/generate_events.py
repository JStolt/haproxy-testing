import random
import argparse
from faker import Faker
import requests

# Linux Box Time, 1000 Events: 1 minute 35 seconds

parser = argparse.ArgumentParser(description='Process some events.')
parser.add_argument('-n', '--number', type=int, required=True,
                    help='number of requests to generate')
parser.add_argument('-t', '--test', type=str, required=False, default=None,
                    help='a string to label this test batch for trial purposes')
parser.add_argument('-c', '--curl', type=str, required=False, default='False',
                    choices=['True', 'False'],
                    help='when True, output curl commands to terminal')

args = parser.parse_args()

def main(args):
    fake = Faker()
    url = "https://endpoint.pixel.eks.dev.605.nu"
    curl = True if args['curl'] == 'True' else False
    # Set up a few test clients/pixels/campaigns
    # These cannot be random, and need to maintain relation
    # clientID: [(pixelID, campgainID)]
    fake_ids = {
        5003: [(123, 33233), (678, 61847), (123, 44444)],
        7423: [(884, 11229), (992, 73526)],
        1444: [(390, 51842), (221, 18032), (943, 66934)]
    }
    for x in range(args['number']):
        client_id = random.choice(list(fake_ids.keys()))
        pixel_choice = random.choice(fake_ids[client_id])
        pixel_id = pixel_choice[0]
        campaign_id = pixel_choice[1]
        items = random.randint(1, 20)
        value = round(random.uniform(1.00, 1000.00), 2)
        time_on_page = random.randint(1, 10000)
        referer = fake.url() # set header
        x_forwarded_for = fake.ipv4() # set header
        user_agent = fake.user_agent() # set header
        webpage = fake.uri_page()
        event = random.choices(
            population = ['click', 'buy', 'keypress', 'select',
                          'input', 'abort', 'close', 'timeout'],
            weights = [0.3, 0.3, 0.1, 0.1, 0.05, 0.05, 0.05, 0.05]
        )[0]

        querystring = {
            "pixelID": pixel_id,
            "clientID": client_id,
            "campaignID": campaign_id,
            "webpage": webpage,
            "event": event,
            "timeOnPage": time_on_page,
            "itemsInCart": items,
            "valueInCart": value
        }
        if args['test']:
            querystring['testBatch'] = args['test']

        payload = ""
        headers = {
            "Referer": referer,
            "X-Forwarded-For": x_forwarded_for,
            "User-Agent": user_agent
        }

        if curl is True:
            curl_stmt = "curl --request GET --url '{0}?{1} --header {2}'".format(
                url,
                ''.join([k+'='+str(v)+'&' for k, v in querystring.items()])[:-1] + "'",
                ' --header '.join("'"+k+':'+v+"'" for k, v in headers.items())[:-1]
            )
            print(curl_stmt)
        else:
            response = requests.request(
                "GET",
                url,
                data=payload,
                headers=headers,
                params=querystring)
            # print(
            #     "Registered event for: client:{}, pixel:{}, campaign:{}".format(
            #         client_id, pixel_id, campaign_id))


if __name__ == "__main__":
    main(vars(args))
