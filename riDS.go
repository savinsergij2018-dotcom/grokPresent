package main

import (
	"bufio"
	"fmt"
	"net"
	"sync"
	"time"
)

type Hub struct {
	nodes      map[string]net.Conn
	broadcast  chan []byte
	register   chan net.Conn
	unregister chan net.Conn
	mu         sync.Mutex
}

func NewHub() *Hub {
	return &Hub{
		nodes:      make(map[string]net.Conn),
		broadcast:  make(chan []byte),
		register:   make(chan net.Conn),
		unregister: make(chan net.Conn),
	}
}

func (h *Hub) Run() {
	for {
		select {
		case conn := <-h.register:
			h.mu.Lock()
			h.nodes[conn.RemoteAddr().String()] = conn
			h.mu.Unlock()
		case conn := <-h.unregister:
			h.mu.Lock()
			if _, ok := h.nodes[conn.RemoteAddr().String()]; ok {
				delete(h.nodes, conn.RemoteAddr().String())
				conn.Close()
			}
			h.mu.Unlock()
		case message := <-h.broadcast:
			h.mu.Lock()
			for addr, conn := range h.nodes {
				go func(c net.Conn, a string) {
					_, err := c.Write(message)
					if err != nil {
						h.unregister <- c
					}
				}(conn, addr)
			}
			h.mu.Unlock()
		}
	}
}

func handle(hub *Hub, conn net.Conn) {
	defer func() {
		hub.unregister <- conn
	}()
	hub.register <- conn
	scanner := bufio.NewScanner(conn)
	for scanner.Scan() {
		msg := scanner.Text()
		hub.broadcast <- []byte(fmt.Sprintf("[%s] %s\n", time.Now().Format("15:04:05"), msg))
	}
}

func main() {
	listener, err := net.Listen("tcp", ":9090")
	if err != nil {
		return
	}
	defer listener.Close()

	hub := NewHub()
	go hub.Run()

	for {
		conn, err := listener.Accept()
		if err != nil {
			continue
		}
		go handle(hub, conn)
	}
}
