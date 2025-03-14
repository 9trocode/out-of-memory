// memory-hog.js
const os = require('os');

console.log("Starting Node.js memory hog simulation...");

// Array to store memory-consuming data
let memoryHog = [];

function consumeMemory() {
    console.log(`Current memory usage: ${(process.memoryUsage().rss / 1024 / 1024).toFixed(2)} MB`);
    try {
        // Allocate 10MB chunks every second
        const chunk = Buffer.alloc(10 * 1024 * 1024, 'x'); // 10MB buffer
        memoryHog.push(chunk);
        console.log(`Allocated 10MB chunk. Total chunks: ${memoryHog.length}`);
    } catch (err) {
        console.error("Error during memory allocation:", err);
        // Optionally simulate a crash here
        process.abort(); // This will cause exit code 134
    }
}

// Simulate memory consumption
setInterval(consumeMemory, 1000);

// Optional: Simulate a crash after 5 seconds (uncomment to test exit code 134)
// setTimeout(() => {
//     console.log("Simulating a crash with process.abort()...");
//     process.abort(); // Exit code 134
// }, 5000);

// Keep the process running
console.log(`Running on ${os.hostname()} with PID ${process.pid}`);