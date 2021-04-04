import random
from faker import Faker

fake = Faker()

print(fake.chrome())

# clientID: [(pixelID, campgainID)]
fake_ids = {
    5003: [(123, 33233), (678, 61847), (123, 44444)]
}


# fixed value for Pixel ID, CLient ID, and Campaign ID
# integers for items in cart, value in cart, time on page
# webpage, event can be form predefined list

# pixel_id



foo = ['a', 'b', 'c', 'd', 'e']
print(random.choice(foo))

# client_id =
#
# clientID={clientid}
#
# web_page={page}
#
# event={event}
#
# source={source}
#
# time_on_page={time}
#
# items_in_cart={#Items}
#
# value_in_cart={$}
#
# IP Address
#
# referer
#
# User agent from browser if it exists
