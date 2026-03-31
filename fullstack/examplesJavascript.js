//  Safe destructuring with defaults
const { b = null, a: { c } = {} } = { a: null, b: 10 };

// Destructured object parameters
function createUser({ name = "Guest", age = 18 } = {}) {}
function f({ a, b: { c } }) {}

// undefined will be omitted from stringify
JSON.stringify({ a: undefined, b: null });
// {"b":null}

// Poly fill for map
Array.prototype.myMap = function (callback, thisArg) {
  if (typeof callback !== "function") {
    throw new TypeError(callback + " is not a function");
  }

  const result = [];
  for (let i = 0; i < this.length; i++) {
    if (i in this) {
      result[i] = callback.call(thisArg, this[i], i, this);
    }
  }
  return result;
};

// Exaple for debounce
function debounce(func, delay) {
  let timeoutId;
  return function (...args) {
    const context = this;
    clearTimeout(timeoutId);
    timeoutId = setTimeout(function () {
      func.apply(context, args);
    }, delay);
  };
}

// --------------------------------- SLIDING WINDOW ALGORITHM ---------------------------------

// The monotonic deque rule:

// Before adding a new element, kick out everything from the back that is smaller than it — they can never be the max while this new element is in the window
// Kick out from the front if that index has slid out of the window
// Front of deque is always the current window's maximum

function maxSlidingWindow(nums, k) {
  const deque = []; // stores indices
  const result = [];

  for (let i = 0; i < nums.length; i++) {
    // 1. Remove indices outside the window
    if (deque.length && deque[0] <= i - k) deque.shift();

    // 2. Remove smaller elements from the back
    //    (they can never be max while nums[i] is here)
    while (deque.length && nums[deque.at(-1)] < nums[i]) deque.pop();

    deque.push(i);

    // 3. Record max for this window position (once we've seen k elements)
    if (i >= k - 1) result.push(nums[deque[0]]);
  }

  return result;
}

// Permutations of an array or string
var permute = function (nums) {
  if (nums.length <= 1) return [nums];
  const result = [];

  for (let i = 0; i < nums.length; i++) {
    const rest = [...nums.slice(0, i), ...nums.slice(i + 1)];
    const perms = permute(rest);
    for (const perm of perms) {
      result.push([nums[i], ...perm]);
    }
  }
  return result;
};
```

## Core Idea

> **Pick one element, recursively permute the rest, prepend the picked element.**

For `[(1, 2, 3)]`:

pick 1 + permute([2,3]) → [1,2,3], [1,3,2]
pick 2 + permute([1,3]) → [2,1,3], [2,3,1]
pick 3 + permute([1,2]) → [3,1,2], [3,2,1]
```;
