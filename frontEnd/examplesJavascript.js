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
