//  Safe destructuring with defaults
const { b = null, a: { c } = {} } = { a: null, b: 10 };

// Destructured object parameters
function createUser({ name = "Guest", age = 18 } = {}) {}
function f({ a, b: { c } }) {}

JSON.stringify({ a: undefined, b: null });
// {"b":null}
