const p1 = new Promise((resolve, reject) => {
  setTimeout(() => {
    resolve("Promise 1 resolved");
  }, 10000);
});

const p2 = new Promise((resolve, reject) => {
  setTimeout(() => {
    resolve("Promise 2 resolved");
  }, 5000);
});

async function hello1() {
  console.log("hello1");
  const result1 = await p1;
  console.log("result1", result1);
  const result2 = await p2;
  console.log("result2", result2);
}

async function hello2() {
  console.log("hello2");
  const result1 = await p1;
  console.log("result21", result1);
  const result2 = await p2;
  console.log("result22", result2);
}

await hello1();
await hello2();
