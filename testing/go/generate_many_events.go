package main

import (
	// "fmt"
	// "log"
	"flag"
	"time"
	"sync"
	"strconv"
	"math/rand"
	"net/http"
	// "net/url"
	"syreclabs.com/go/faker"
	"github.com/EDDYCJY/fake-useragent"
	wr "github.com/mroth/weightedrand"
)

// GO RUN TIME, 1000 EVENTS: 2.310 Seconds
// GO BUILD BINARY EXECUTION TIME, 1000 EVENTS: 1.757 Seconds


// implement "tuple" data type because it seemed easier
type Pair [2]interface{}


func main() {
		rand.Seed(time.Now().UTC().UnixNano()) // always seed random!

		runs := flag.Int("num", 1, "number of requests to run")
		test := flag.String("test", "None", "test batch tag to apply to data")
		_=test
		flag.Parse()

		ids := make(map[int][]Pair)
		case_1 := []Pair{{2737, 69741}}
		case_2 := []Pair{{6433, 93299}, {7308, 29135}}
		case_3 := []Pair{{7839, 59161}, {4630, 56156}, {9847, 53716}}
		case_4 := []Pair{{1601, 43254}, {5844, 75953}, {5701, 93396},
										 {7110, 82885}}
		case_5 := []Pair{{9244, 93144}, {8107, 20221}, {1656, 20041},
										 {8664, 54498}, {4491, 24743}}
		ids[1111] = case_1
		ids[2222] = case_2
		ids[3333] = case_3
		ids[4444] = case_4
		ids[5555] = case_5

		client_choice, _ := wr.NewChooser(
				wr.Choice{Item: 1111, Weight: 1},
				wr.Choice{Item: 2222, Weight: 1},
				wr.Choice{Item: 3333, Weight: 2},
				wr.Choice{Item: 4444, Weight: 2},
				wr.Choice{Item: 5555, Weight: 4},
		)

		// TODO: Finalize Request Limit Circumvention Option
		// Explanation: The backend service for this test restricts requst limit
		// to 1000/second.  For speed and concurrency, goroutines are being used
		// to execute the requests, but with goroutines, it can be a little tricky
		// to fine-tune for batch execution or execution delays, to buffer the rate
		// at which the requests are sent.  Sleeping directly after a goroutine is
		// called has not resolved the issue, nor have a couple different waitgroup
		// batching attempts.  Additionally, no differing results were seen between
		// instantiating an http_client per goroutine vs sharing one amongst all
		// goroutines.  A ticker will be attempted next, but pushing commit
		// now so that small tests be run.
		http_client := &http.Client{}

		// Option 1 - Sleep after Goroutine
		wg := new(sync.WaitGroup)
		for i := 1; i < *runs+1; i++ {
			client := client_choice.Pick().(int)
			pix_camp_combo := ids[client][rand.Intn(len(ids[client]))]
			wg.Add(1)
			go run_requests(client, pix_camp_combo, *test, http_client, wg)
			// time.Sleep(2 * time.Millisecond)
		}
		wg.Wait()

		// Option 2 - Set batch size and sleep when i mod batch is 0 (sleep every batch)
		// batch := 1000
		// for i := 1; i < *runs+1; i++ {
		// 	if i % batch == 0{
		// 		wg := new(sync.WaitGroup)
		// 		for i := 0; i < batch; i++{
		// 			client := client_choice.Pick().(int)
		// 			pix_camp_combo := ids[client][rand.Intn(len(ids[client]))]
		// 			wg.Add(1)
		// 			go run_requests(client, pix_camp_combo, *test, http_client, &wg)
		// 		}
		// 		wg.Wait()
		// 		time.Sleep(10 * time.Second)
		// 	}
		// }

		// Option 3 - Increment by batch, running that batches request in a subloop
		// batch := 1000
		// for i := 1; i < *runs+1; i += batch {
		// 	wg := new(sync.WaitGroup)
		// 	for i := 0; i < batch; i++ {
		// 		client := client_choice.Pick().(int)
		// 		pix_camp_combo := ids[client][rand.Intn(len(ids[client]))]
		// 		wg.Add(1)
		// 		go run_requests(client, pix_camp_combo, *test, wg)
		// 	}
		// 	wg.Wait()
		// 	time.Sleep(10 * time.Second)
		// }

}





func run_requests(client int, combo Pair, test string, http_client *http.Client, wg *sync.WaitGroup) {
	defer wg.Done()
	rand.Seed(time.Now().UTC().UnixNano()) // always seed random!
	event_choice, _ := wr.NewChooser(
			wr.Choice{Item: "click", Weight: 30},
			wr.Choice{Item: "buy", Weight: 30},
			wr.Choice{Item: "keypress", Weight: 10},
			wr.Choice{Item: "select", Weight: 10},
			wr.Choice{Item: "input", Weight: 10},
			wr.Choice{Item: "abort", Weight: 5},
			wr.Choice{Item: "timeout", Weight: 5},
	)

	host := "http://127.0.0.1/?"
	pixel := combo[0].(int)
	campaign := combo[1].(int)
	items := rand.Intn(30)
	value := rand.Intn(1000)
	page_time := rand.Intn(10000)
	// Internet Stuff
	webpage := faker.Internet().Slug()
	event := event_choice.Pick().(string)
	// Headers
	referer := faker.Internet().Url()
	x_forwarded_for := faker.Internet().IpV4Address()
	user_agent := browser.Random()

	my_url := host + "clientId=" + strconv.Itoa(client) + "&pixelID=" +
						strconv.Itoa(pixel) + "&campaignID=" + strconv.Itoa(campaign) +
						"&webpage=" + webpage + "&event=" + event + "&timeOnPage=" +
						strconv.Itoa(page_time) + "&itemsInCart=" + strconv.Itoa(items) +
						"&valueInCart=" + strconv.Itoa(value)

	if test != "None" {
		my_url = my_url + "&testBatch=" + test
	}

	req, err := http.NewRequest("GET", my_url, nil)
	req.Header.Add("Referer", referer)
	req.Header.Add("X-Forwarded-For", x_forwarded_for)
	req.Header.Add("User-Agent", user_agent)
	resp, err := http_client.Do(req)

	// No need to handle response errors yet
	_ = resp
	_ = err

}
