package main

// Unsynchronised send and close operations on the same channel can also be a race condition.
func UnsynchronisedChannel() {
	c := make(chan int)

	go func() {
		c <- 1
	}()

	close(c)
}

// To synchronise send and close operations, use a receive operation that guarantees the send is
// done before the close.
func UnsynchronisedChannelFixed() {
	c := make(chan int)

	go func() {
		c <- 1
	}()

	<-c
	close(c)
}
