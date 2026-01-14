use std::sync::{Arc, Mutex};
use std::thread;
use std::net::TcpStream;
use std::io::{Read, Write};

struct TaskQueue {
    tasks: Vec<String>,
}

impl TaskQueue {
    fn new() -> Self {
        Self { tasks: Vec::new() }
    }

    fn add(&mut self, task: String) {
        self.tasks.push(task);
    }
}

fn worker(queue: Arc<Mutex<TaskQueue>>) {
    loop {
        let mut q = queue.lock().unwrap();
        if let Some(task) = q.tasks.pop() {
            println!("Processing: {}", task);
        }
        drop(q);
        thread::sleep(std::time::Duration::from_millis(500));
    }
}

fn main() {
    let queue = Arc::new(Mutex::new(TaskQueue::new()));
    let q_clone = Arc::clone(&queue);

    thread::spawn(move || worker(q_clone));

    {
        let mut q = queue.lock().unwrap();
        q.add("INTERNAL_SCAN".to_string());
        q.add("MEMORY_PURGE".to_string());
    }

    thread::sleep(std::time::Duration::from_secs(2));
}
