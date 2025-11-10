export default {
    testEnvironment: "node",
    transform: {
        "^.+\\.js$": "babel-jest",
    },
    testMatch: ["**/test/**/*.test.js"],
    collectCoverage: true,
    collectCoverageFrom: ["src/**/*.js"],
    coverageDirectory: "coverage",
    verbose: true,
};
